//
//  RealTimeChordViewModel.swift
//  guitar-strumpattern-detection
//

import CoreML
import Foundation
import SwiftUI
import Combine

// MARK: - RealTimeChordEngine

nonisolated final class RealTimeChordEngine: @unchecked Sendable {

    private let modelNames: [String]
    private let modelRunners: [ChordNetModelRunner]
    private let decoder: ChordXHMMDecoder?

    private let audioQueue = DispatchQueue(label: "com.guitar.realtime.buffer", qos: .userInitiated)
    private let inferenceQueue = DispatchQueue(label: "com.guitar.realtime.inference", qos: .userInitiated)

    private var sampleBuffer: [Float] = []
    private var lastAnalysisTime: CFAbsoluteTime = 0
    private var isInferenceRunning = false

    private let maxBufferSamples = Int(AudioLoader.targetSampleRate * 6)
    private let minBufferSamples = Int(AudioLoader.targetSampleRate * 2)
    private let analysisInterval: CFAbsoluteTime = 0.5

    var onChordDetected: (@Sendable (String) -> Void)?
    var onError: (@Sendable (String) -> Void)?
    var onAnalyzingChanged: (@Sendable (Bool) -> Void)?

    init(modelNames: [String], modelRunners: [ChordNetModelRunner], decoder: ChordXHMMDecoder?) {
        self.modelNames = modelNames
        self.modelRunners = modelRunners
        self.decoder = decoder
    }

    func reset() {
        audioQueue.async {
            self.sampleBuffer.removeAll(keepingCapacity: false)
            self.lastAnalysisTime = 0
            self.isInferenceRunning = false
        }
    }

    func processSamples(_ samples: [Float]) {
        audioQueue.async {
            self.sampleBuffer.append(contentsOf: samples)
            if self.sampleBuffer.count > self.maxBufferSamples {
                self.sampleBuffer.removeFirst(self.sampleBuffer.count - self.maxBufferSamples)
            }

            let now = CFAbsoluteTimeGetCurrent()
            guard self.sampleBuffer.count >= self.minBufferSamples,
                  now - self.lastAnalysisTime >= self.analysisInterval,
                  !self.isInferenceRunning else { return }

            self.lastAnalysisTime = now
            self.isInferenceRunning = true
            let snapshot = self.sampleBuffer

            self.onAnalyzingChanged?(true)

            self.inferenceQueue.async {
                defer {
                    self.audioQueue.async {
                        self.isInferenceRunning = false
                    }
                    self.onAnalyzingChanged?(false)
                }

                do {
                    let chord = try self.detectChord(from: snapshot)
                    self.onChordDetected?(chord)
                } catch {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    private func detectChord(from samples: [Float]) throws -> String {
        guard !modelRunners.isEmpty else {
            throw ChordNetModelError.modelNotFound(modelNames.joined(separator: ", "))
        }

        guard let hybridCQT = HybridCQT.shared else {
            throw ChordNetModelError.predictionFailed("CQT filterbanks not available.")
        }
        let cqtFrames = try hybridCQT.compute(samples: samples)
        guard !cqtFrames.isEmpty else {
            throw ChordNetModelError.predictionFailed("CQT produced no frames.")
        }

        let flatCQT = cqtFrames.flatMap { $0 }
        let input = try MLMultiArrayBuilder.makeCQTInput(frames: cqtFrames.count, slice: flatCQT)

        let outputsList = try modelRunners.map { try $0.predict(cqt: input) }
        let outputs: [String: MLMultiArray]
        if outputsList.count == 1, let first = outputsList.first {
            outputs = first
        } else {
            outputs = try ChordNetModelRunner.averageOutputs(outputsList)
        }

        let headOutputs = try ChordNetOutputParser.parse(outputs)

        if let decoder,
           let result = decoder.decode(triad: headOutputs.triad,
                                       bass: headOutputs.bass,
                                       seventh: headOutputs.seventh,
                                       ninth: headOutputs.ninth,
                                       eleventh: headOutputs.eleventh,
                                       thirteenth: headOutputs.thirteenth),
           let label = result.labels.last {
            return label
        }

        let triadIndices = Self.classIndices(from: headOutputs.triad)
        guard let lastIndex = triadIndices.last else {
            throw ChordNetModelError.predictionFailed("No chord frames decoded.")
        }

        let triadLabels = Self.triadLabels()
        if lastIndex >= 0, lastIndex < triadLabels.count {
            return triadLabels[lastIndex]
        }
        return "N"
    }

    private static func classIndices(from triad: MLMultiArray) -> [Int] {
        let shape = triad.shape.map { Int(truncating: $0) }
        let strides = triad.strides.map { Int(truncating: $0) }

        let (frames, classes, frameStride, classStride): (Int, Int, Int, Int)
        if shape.count == 3, shape[0] == 1 {
            frames = shape[1]
            classes = shape[2]
            frameStride = strides[1]
            classStride = strides[2]
        } else if shape.count == 2 {
            frames = shape[0]
            classes = shape[1]
            frameStride = strides[0]
            classStride = strides[1]
        } else if shape.count >= 2 {
            frames = shape[shape.count - 2]
            classes = shape[shape.count - 1]
            frameStride = strides[strides.count - 2]
            classStride = strides[strides.count - 1]
        } else {
            return []
        }

        var classIndices = [Int](repeating: 0, count: frames)

        switch triad.dataType {
        case .float32:
            let ptr = triad.dataPointer.bindMemory(to: Float.self, capacity: triad.count)
            for frame in 0..<frames {
                var bestIndex = 0
                var bestValue = -Float.greatestFiniteMagnitude
                for classIndex in 0..<classes {
                    let idx = frame * frameStride + classIndex * classStride
                    let value = ptr[idx]
                    if value > bestValue {
                        bestValue = value
                        bestIndex = classIndex
                    }
                }
                classIndices[frame] = bestIndex
            }
        case .double:
            let ptr = triad.dataPointer.bindMemory(to: Double.self, capacity: triad.count)
            for frame in 0..<frames {
                var bestIndex = 0
                var bestValue = -Double.greatestFiniteMagnitude
                for classIndex in 0..<classes {
                    let idx = frame * frameStride + classIndex * classStride
                    let value = ptr[idx]
                    if value > bestValue {
                        bestValue = value
                        bestIndex = classIndex
                    }
                }
                classIndices[frame] = bestIndex
            }
        default:
            return []
        }

        return classIndices
    }

    private static func triadLabels() -> [String] {
        let roots = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        let triads = ["maj", "min", "sus4", "sus2", "dim", "aug"]
        var labels = ["N"]
        for triad in triads {
            for root in roots {
                labels.append("\(root):\(triad)")
            }
        }
        return labels
    }
}

// MARK: - SoundGate

nonisolated final class SoundGate: @unchecked Sendable {
    private let lock = NSLock()
    private var lastSoundTime = Date.distantPast
    private var previousRMS: Float = 0
    private var isWarmedUp = false
    private var baseThreshold: Float = AudioThresholdMapper.rmsFloor(fromDecibels: -45)
    private var spikeThreshold: Float = AudioThresholdMapper.rmsSpike(fromDecibels: 3)

    func configure(baseDecibels: Float, spikeDecibels: Float) {
        lock.lock()
        baseThreshold = AudioThresholdMapper.rmsFloor(fromDecibels: baseDecibels)
        spikeThreshold = AudioThresholdMapper.rmsSpike(fromDecibels: spikeDecibels)
        lock.unlock()
    }

    func reset() {
        lock.lock()
        lastSoundTime = Date.distantPast
        previousRMS = 0
        isWarmedUp = false
        lock.unlock()
    }

    func registerSamples(_ samples: [Float]) {
        guard !samples.isEmpty else { return }
        let rms = sqrt(samples.reduce(0) { $0 + $1 * $1 } / Float(samples.count))

        lock.lock()
        defer { lock.unlock() }

        guard isWarmedUp else {
            previousRMS = rms
            isWarmedUp = true
            return
        }

        let jump = rms - previousRMS
        previousRMS = rms

        if rms > baseThreshold && jump > spikeThreshold {
            lastSoundTime = Date()
        }
    }

    func isDetected(within seconds: TimeInterval = 0.3) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return Date().timeIntervalSince(lastSoundTime) < seconds
    }
}

// MARK: - RealTimeChordViewModel

@MainActor
final class RealTimeChordViewModel: ObservableObject {

    @Published var currentChord: String = "--"
    @Published var isListening = false
    @Published var isAnalyzing = false
    @Published var isSoundGateOpen = false
    @Published var errorMessage: String?

    private var detector: RealTimeAudioDetector?
    private let engine: RealTimeChordEngine
    private let soundGate = SoundGate()

    init(modelNames: [String] = ["ChordNet_s0", "ChordNet_s1", "ChordNet_s2", "ChordNet_s3", "ChordNet_s4"]) {
        let runners = modelNames.compactMap { try? ChordNetModelRunner(modelName: $0) }
        let decoder: ChordXHMMDecoder?
        if let mapping = try? ChordMapping.load() {
            decoder = ChordXHMMDecoder(mapping: mapping)
        } else {
            decoder = nil
        }

        let engine = RealTimeChordEngine(modelNames: modelNames, modelRunners: runners, decoder: decoder)
        self.engine = engine

        engine.onChordDetected = { [weak self] chord in
            Task { @MainActor in
                self?.applyDetectedChord(chord)
            }
        }
        engine.onError = { [weak self] message in
            Task { @MainActor in
                self?.errorMessage = message
            }
        }
        engine.onAnalyzingChanged = { [weak self] isAnalyzing in
            Task { @MainActor in
                self?.isAnalyzing = isAnalyzing
            }
        }
    }

    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    func isSoundDetected() -> Bool {
        soundGate.isDetected()
    }

    func updateSoundThresholds(baseDecibels: Float, spikeDecibels: Float) {
        soundGate.configure(baseDecibels: baseDecibels, spikeDecibels: spikeDecibels)
    }

    func startListening() {
        errorMessage = nil
        currentChord = "--"

        do {
            let detector = RealTimeAudioDetector()
            let engine = engine
            let soundGate = soundGate
            detector.onSamples = { [weak self] samples in
                soundGate.registerSamples(samples)
                let isOpen = soundGate.isDetected()
                Task { @MainActor in
                    self?.isSoundGateOpen = isOpen
                }
                engine.processSamples(samples)
            }
            try detector.startListening()
            self.detector = detector
            isListening = true
        } catch {
            errorMessage = error.localizedDescription
            isListening = false
        }
    }

    func stopListening() {
        detector?.stopListening()
        detector = nil
        isListening = false
        isAnalyzing = false
        isSoundGateOpen = false
        soundGate.reset()
        engine.reset()
    }

    private func applyDetectedChord(_ chord: String) {
        guard !chord.isEmpty else { return }
        currentChord = chord
    }
}

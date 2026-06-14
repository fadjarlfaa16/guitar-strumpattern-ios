//
//  ChordAnalyzer.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 10/06/26.
//

import CoreML
import Foundation

/// Complete chord analysis result
struct ChordAnalysisResult {
    let bpm: Int
    let timeSignature: String
    let chordSegments: [StoredChordSegment]
}

/// Orchestrates full chord detection pipeline
final class ChordAnalyzer {
    static let shared = ChordAnalyzer()
    private init() {}

    private static let ensembleModelNames = (0...4).map { "ChordNet_s\($0)" }

    /// Run complete analysis: BPM → TimeSignature → Chord detection
    func analyze(audioURL: URL, onProgress: (@Sendable (Double, String) -> Void)? = nil) throws -> ChordAnalysisResult {
        // Step 1: Load Audio
        onProgress?(0.08, "Loading audio file...")
        UploadLogger.log("Starting Analyze: \(audioURL.lastPathComponent)")
        let samples = try AudioLoader.load(url: audioURL)
        guard !samples.isEmpty else {
            throw NSError(domain: "ChordAnalyzer", code: -4,
                         userInfo: [NSLocalizedDescriptionKey: "Error while loading audio: audio file is empty."])
        }
        UploadLogger.log("Audio loaded: \(samples.count) samples, \(String(format: "%.2f", Double(samples.count) / AudioLoader.targetSampleRate))s")
        try Task.checkCancellation()

        // Step 2: Analyze BPM and Time Signature
        onProgress?(0.22, "Analyzing BPM & time signature...")
        UploadLogger.log("BPM/time signature mulai")
        let audioAnalysis = BPMTimeSignatureAnalyzer.shared.analyze(samples: samples)
        UploadLogger.log("BPM/time signature selesai: \(audioAnalysis.bpm) BPM, \(audioAnalysis.timeSignature)")
        try Task.checkCancellation()

        // Step 3: Compute CQT features
        guard let hybridCQT = HybridCQT.shared else {
            throw NSError(domain: "ChordAnalyzer", code: -5,
                         userInfo: [NSLocalizedDescriptionKey: "CQT filterbanks not available."])
        }
        onProgress?(0.30, "Computing spectral features (CQT)...")
        UploadLogger.log("HybridCQT started")
        let cqtMat = try hybridCQT.compute(samples: samples)
        UploadLogger.log("HybridCQT finished: \(cqtMat.count) frames")
        try Task.checkCancellation()

        // Step 4: Build CQT input for model
        let frames = cqtMat.count
        guard frames > 0 else {
            throw NSError(domain: "ChordAnalyzer", code: -6,
                         userInfo: [NSLocalizedDescriptionKey: "CQT couldn't be built. Try to find another file."])
        }
        onProgress?(0.48, "Building feature matrix...")
        UploadLogger.log("Build MLMultiArray started: frames=\(frames)")
        let cqtInput = try MLMultiArrayBuilder.makeCQTInput(matrix: cqtMat)
        UploadLogger.log("Build MLMultiArray finished")
        try Task.checkCancellation()

        // Step 5: Run ChordNet ensemble (s0–s4)
        var ensembleOutputs: [[String: MLMultiArray]] = []
        ensembleOutputs.reserveCapacity(Self.ensembleModelNames.count)
        for (i, modelName) in Self.ensembleModelNames.enumerated() {
            try Task.checkCancellation()
            onProgress?(0.52 + Double(i) * 0.06, "Neural net inference (\(i + 1)/5)...")
            UploadLogger.log("CoreML predict start: \(modelName)")
            let runner = try ChordNetModelRunner(modelName: modelName)
            ensembleOutputs.append(try runner.predict(cqt: cqtInput))
            UploadLogger.log("CoreML predict finish: \(modelName)")
        }

        // Step 6: Average ensemble outputs
        onProgress?(0.80, "Combining model outputs...")
        UploadLogger.log("Average ensemble output mulai")
        let outputs = try ChordNetModelRunner.averageOutputs(ensembleOutputs)
        UploadLogger.log("Average ensemble output selesai")

        // Step 7: Parse model outputs
        onProgress?(0.84, "Parsing chord predictions...")
        UploadLogger.log("Parse model output mulai")
        let parsed = try ChordNetOutputParser.parse(outputs)
        UploadLogger.log("Parse model output selesai")

        // Step 8: HMM decode
        onProgress?(0.88, "Decoding chord sequences...")
        UploadLogger.log("HMM decode mulai")
        let mapping = try ChordMapping.load()
        let decoder = ChordXHMMDecoder(mapping: mapping, diffTransPenalty: 30.0)

        guard let (_, labels) = decoder.decode(
            triad: parsed.triad,
            bass: parsed.bass,
            seventh: parsed.seventh,
            ninth: parsed.ninth,
            eleventh: parsed.eleventh,
            thirteenth: parsed.thirteenth
        ) else {
            throw NSError(domain: "ChordAnalyzer", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "HMM decoding failed"])
        }

        // Step 9: Build chord timeline
        onProgress?(0.93, "Building chord timeline...")
        let adjustedLabels = ChordAdjuster.adjust(labels)
        let segments = frameIndicesToSegments(labels: adjustedLabels)
        UploadLogger.log("Analisis selesai: \(segments.count) chord segments")

        return ChordAnalysisResult(
            bpm: audioAnalysis.bpm,
            timeSignature: audioAnalysis.timeSignature,
            chordSegments: segments
        )
    }

    // MARK: - Helper: Frame → Time Conversion

    /// Convert frame-level chord labels to time-based segments
    /// - HybridCQT hop length varies per octave, using avg ~512 samples
    /// - Average frame rate ≈ 22050 Hz / 512 samples ≈ 43 frames/sec
    private func frameIndicesToSegments(labels: [String]) -> [StoredChordSegment] {
        guard !labels.isEmpty else { return [] }

        // Average hop length across octaves is approximately 512 samples at 22050 Hz
        let avgHopLength: Float = 512
        let sampleRate: Float = 22050
        let frameTime = avgHopLength / sampleRate  // seconds per frame

        var segments: [StoredChordSegment] = []
        var currentLabel = labels[0]
        var segmentStart = 0

        for (frameIdx, label) in labels.enumerated() {
            if label != currentLabel {
                // Create segment for previous label
                let startTime = TimeInterval(frameIdx) * TimeInterval(frameTime)
                let segment = StoredChordSegment(
                    startTime: TimeInterval(segmentStart) * TimeInterval(frameTime),
                    endTime: startTime,
                    label: currentLabel
                )
                segments.append(segment)

                currentLabel = label
                segmentStart = frameIdx
            }
        }

        // Add final segment
        let finalStartTime = TimeInterval(segmentStart) * TimeInterval(frameTime)
        let finalEndTime = TimeInterval(labels.count) * TimeInterval(frameTime)
        segments.append(StoredChordSegment(
            startTime: finalStartTime,
            endTime: finalEndTime,
            label: currentLabel
        ))

        return segments
    }
}

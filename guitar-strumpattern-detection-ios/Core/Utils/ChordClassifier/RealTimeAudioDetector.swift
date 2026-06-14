//
//  RealTimeAudioDetector.swift
//  guitar-strumpattern-detection-ios
//

import AVFoundation

final class RealTimeAudioDetector {

    var onSamples: (([Float]) -> Void)?

    private let engine = AVAudioEngine()
    private var converter: AVAudioConverter?
    private var targetFormat: AVAudioFormat?
    private let processingQueue = DispatchQueue(label: "com.guitar.realtime.detector", qos: .userInitiated)

    func startListening() throws {
        stopListening()

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true)

        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        guard let targetFmt = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: AudioLoader.targetSampleRate,
            channels: 1,
            interleaved: false
        ) else {
            throw Self.makeError("Failed to create target audio format.")
        }

        guard let audioConverter = AVAudioConverter(from: inputFormat, to: targetFmt) else {
            throw Self.makeError("AVAudioConverter could not convert microphone input.")
        }

        targetFormat = targetFmt
        converter = audioConverter

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.processingQueue.async {
                self?.process(buffer: buffer)
            }
        }

        engine.prepare()
        try engine.start()
    }

    func stopListening() {
        if engine.isRunning {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        converter = nil
        targetFormat = nil
    }

    private func process(buffer: AVAudioPCMBuffer) {
        guard let converter, let targetFormat else { return }

        let ratio = AudioLoader.targetSampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 512
        guard let output = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }

        var conversionError: NSError?
        var consumed = false

        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            if consumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            consumed = true
            outStatus.pointee = .haveData
            return buffer
        }

        let status = converter.convert(to: output, error: &conversionError, withInputFrom: inputBlock)
        if let conversionError {
            print("[RealTimeAudioDetector] Conversion error: \(conversionError.localizedDescription)")
            return
        }
        guard status != .error else { return }

        guard let channelData = output.floatChannelData else { return }
        let frameLength = Int(output.frameLength)
        guard frameLength > 0 else { return }

        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
        onSamples?(samples)
    }

    private static func makeError(_ message: String) -> NSError {
        NSError(domain: "RealTimeAudioDetector", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

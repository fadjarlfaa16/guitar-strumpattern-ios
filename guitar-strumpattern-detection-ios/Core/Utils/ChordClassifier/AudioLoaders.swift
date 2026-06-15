//
//  AudioLoaders.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import AVFoundation

enum AudioLoader {

    nonisolated static let targetSampleRate: Double = 22050

    nonisolated static func load(url: URL) throws -> [Float] {
        try AudioLoader.loadSync(url: url)
    }

    private nonisolated static func loadSync(url: URL) throws -> [Float] {
        let sourceFile = try AVAudioFile(forReading: url)
        let sourceFmt  = sourceFile.processingFormat

        guard let targetFmt = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: targetSampleRate,
            channels: 1,
            interleaved: false
        ) else {
            throw makeError("Failed to create target audio format (22050 Hz mono).")
        }


        guard let converter = AVAudioConverter(from: sourceFmt, to: targetFmt) else {
            throw makeError("AVAudioConverter could not convert from \(sourceFmt) to \(targetFmt).")
        }

        let sourceFrameCount = AVAudioFrameCount(sourceFile.length)
        guard sourceFrameCount > 0 else { return [] }
        guard let sourceBuf = AVAudioPCMBuffer(pcmFormat: sourceFmt, frameCapacity: sourceFrameCount) else {
            throw makeError("Could not allocate source PCM buffer (\(sourceFrameCount) frames).")
        }
        try sourceFile.read(into: sourceBuf)


        let ratio = targetSampleRate / sourceFmt.sampleRate
        let outputCapacity = AVAudioFrameCount(Double(sourceFrameCount) * ratio) + 512
        guard let outputBuf = AVAudioPCMBuffer(pcmFormat: targetFmt, frameCapacity: outputCapacity) else {
            throw makeError("Could not allocate output PCM buffer.")
        }

        var conversionError: NSError?
        let inputState = AudioConverterInputState(buffer: sourceBuf)

        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            inputState.nextBuffer(outStatus: outStatus)
        }

        let status = converter.convert(to: outputBuf, error: &conversionError, withInputFrom: inputBlock)
        if let err = conversionError { throw err }
        guard status != .error else {
            throw makeError("AVAudioConverter conversion failed (status=\(status.rawValue)).")
        }

        guard let channelData = outputBuf.floatChannelData else { return [] }
        let frameLength = Int(outputBuf.frameLength)
        return Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
    }

    private nonisolated static func makeError(_ msg: String) -> NSError {
        NSError(domain: "AudioLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

private final class AudioConverterInputState: @unchecked Sendable {
    private let buffer: AVAudioPCMBuffer
    private let lock = NSLock()
    private var consumed = false

    init(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer
    }

    func nextBuffer(outStatus: UnsafeMutablePointer<AVAudioConverterInputStatus>) -> AVAudioBuffer? {
        lock.lock()
        defer { lock.unlock() }

        if consumed {
            outStatus.pointee = .endOfStream
            return nil
        }

        consumed = true
        outStatus.pointee = .haveData
        return buffer
    }
}

//
//  ChordNetRunner.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//

import CoreML
import Foundation

// MARK: - ChordNetModelRunner

final class ChordNetModelRunner {
    private let model: MLModel

    // Load CoreML for ChordNet
    init(modelName: String) throws {
        let url: URL
        if let compiled = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") {
            url = compiled
        } else if let pkg = Bundle.main.url(forResource: modelName, withExtension: "mlpackage") {
            url = pkg
        } else {
            throw ChordNetModelError.modelNotFound(modelName)
        }
        let config = MLModelConfiguration()

        config.computeUnits = .cpuOnly  // CPU considered karena BiLSTM gabisa pakai GPU
        model = try MLModel(contentsOf: url, configuration: config)
    }

    
    // Declare maximum lenght of music duration
    
    // Duration = Number of Frames × (Hop Length / Sample Rate)
    //  = 50000 × (512 / 22050)
    //  = 50000 × 0.02321 detik/frame
    //  = 1160.8 detik
    //  ≈ 19.35 menit
    private let maxChunkFrames = 50000

    /// - Parameter cqt: shape [1, T, 252] float32
    /// - Returns: dictionary mapping output feature names to MLMultiArrays
    func predict(cqt: MLMultiArray) throws -> [String: MLMultiArray] {
        let shape = cqt.shape.map { Int(truncating: $0) }
        guard shape.count == 3, shape[0] == 1 else {
            return try predictOnce(cqt: cqt)
        }
        let T = shape[1]
        let C = shape[2]

        if T <= maxChunkFrames {
            return try predictOnce(cqt: cqt)
        }

        let cqtPtr = cqt.dataPointer.bindMemory(to: Float.self, capacity: cqt.count)
        var allProbsFlat: [Float] = []
        allProbsFlat.reserveCapacity(T * 100)
        var offset = 0

        while offset < T {
            let chunkLen = min(maxChunkFrames, T - offset)
            let chunk = try MLMultiArray(
                shape: [1, NSNumber(value: chunkLen), NSNumber(value: C)],
                dataType: .float32
            )
            let chunkPtr = chunk.dataPointer.bindMemory(to: Float.self, capacity: chunk.count)
            chunkPtr.initialize(from: cqtPtr + offset * C, count: chunkLen * C)

            let out = try predictOnce(cqt: chunk)
            if let probs = out["chord_probs"] {
                let probPtr = probs.dataPointer.bindMemory(to: Float.self, capacity: probs.count)
                allProbsFlat.append(contentsOf: UnsafeBufferPointer(start: probPtr, count: probs.count))
            }
            offset += chunkLen
        }

        // Rebuild a single 2-D [totalFrames, 100] result array.
        let cols = 100
        let totalFrames = allProbsFlat.count / cols
        let merged = try MLMultiArray(
            shape: [NSNumber(value: totalFrames), NSNumber(value: cols)],
            dataType: .float32
        )
        let mergedPtr = merged.dataPointer.bindMemory(to: Float.self, capacity: merged.count)
        allProbsFlat.withUnsafeBufferPointer { buf in
            mergedPtr.initialize(from: buf.baseAddress!, count: allProbsFlat.count)
        }
        return ["chord_probs": merged]
    }

    private func predictOnce(cqt: MLMultiArray) throws -> [String: MLMultiArray] {
        let input = try MLDictionaryFeatureProvider(dictionary: ["cqt_features": MLFeatureValue(multiArray: cqt)])
        let output = try model.prediction(from: input)
        var result: [String: MLMultiArray] = [:]
        for name in output.featureNames {
            if let value = output.featureValue(for: name), let array = value.multiArrayValue {
                result[name] = array
            }
        }
        return result
    }

    static func averageOutputs(_ list: [[String: MLMultiArray]]) throws -> [String: MLMultiArray] {
        guard let first = list.first else {
            throw ChordNetModelError.predictionFailed("Empty outputs list.")
        }
        guard list.count > 1 else { return first }

        var result: [String: MLMultiArray] = [:]
        for key in first.keys {
            guard let base = first[key] else { continue }
            let count = base.count
            let avgArr = try MLMultiArray(shape: base.shape, dataType: .float32)
            let avgPtr = avgArr.dataPointer.bindMemory(to: Float.self, capacity: count)

            // Copy first array
            if base.dataType == .float32 {
                let src = base.dataPointer.bindMemory(to: Float.self, capacity: count)
                avgPtr.initialize(from: src, count: count)
            } else {
                for i in 0..<count { avgPtr[i] = Float(truncating: base[i]) }
            }

            // Accumulate remaining arrays
            for i in 1..<list.count {
                guard let arr = list[i][key] else { continue }
                if arr.dataType == .float32 {
                    let src = arr.dataPointer.bindMemory(to: Float.self, capacity: count)
                    for j in 0..<count { avgPtr[j] += src[j] }
                } else {
                    for j in 0..<count { avgPtr[j] += Float(truncating: arr[j]) }
                }
            }

            // Divide by count
            let scale = Float(1.0) / Float(list.count)
            for j in 0..<count { avgPtr[j] *= scale }

            result[key] = avgArr
        }
        return result
    }
}

//
//  ChordNetParser.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import CoreML
import Foundation

enum ChordNetOutputParser {

    private static let triadRange:       Range<Int> = 0..<73
    private static let bassRange:        Range<Int> = 73..<86
    private static let seventhRange:     Range<Int> = 86..<90
    private static let ninthRange:       Range<Int> = 90..<94
    private static let eleventhRange:    Range<Int> = 94..<97
    private static let thirteenthRange:  Range<Int> = 97..<100
    private static let expectedCols = 100

    static func parse(_ outputs: [String: MLMultiArray]) throws -> ChordNetOutputs {
        guard let chordProbs = outputs["chord_probs"] else {
            throw ChordNetModelError.predictionFailed("'chord_probs' key not found in model outputs.")
        }

        let shape = chordProbs.shape.map { Int(truncating: $0) }
        let frames: Int
        let totalCols: Int
        if shape.count == 2 {
            frames = shape[0]
            totalCols = shape[1]
        } else if shape.count == 3, shape[0] == 1 {
            frames = shape[1]
            totalCols = shape[2]
        } else {
            throw ChordNetModelError.predictionFailed(
                "Expected chord_probs to be 2D [T, 100] or 3D [1, T, 100], got shape \(shape)."
            )
        }
        guard totalCols >= expectedCols else {
            throw ChordNetModelError.predictionFailed(
                "chord_probs column count \(totalCols) < \(expectedCols)."
            )
        }

        let srcPtr: UnsafeMutablePointer<Float>
        if chordProbs.dataType == .float32 {
            srcPtr = chordProbs.dataPointer.bindMemory(to: Float.self, capacity: chordProbs.count)
        } else {
            // Convert to float32 via a temporary buffer
            var tmp = [Float](repeating: 0, count: chordProbs.count)
            for i in 0..<chordProbs.count { tmp[i] = Float(truncating: chordProbs[i]) }
            let result = try extractAll(from: tmp, frames: frames, totalCols: totalCols)
            return result
        }

        return try extractAll(from: srcPtr, frames: frames, totalCols: totalCols)
    }

    private static func extractAll(from src: UnsafePointer<Float>,frames: Int,totalCols: Int) throws -> ChordNetOutputs {
        return ChordNetOutputs(
            triad:       try extract(src: src, frames: frames, totalCols: totalCols, range: triadRange),
            bass:        try extract(src: src, frames: frames, totalCols: totalCols, range: bassRange),
            seventh:     try extract(src: src, frames: frames, totalCols: totalCols, range: seventhRange),
            ninth:       try extract(src: src, frames: frames, totalCols: totalCols, range: ninthRange),
            eleventh:    try extract(src: src, frames: frames, totalCols: totalCols, range: eleventhRange),
            thirteenth:  try extract(src: src, frames: frames, totalCols: totalCols, range: thirteenthRange)
        )
    }

    private static func extractAll(from src: [Float],frames: Int,totalCols: Int) throws -> ChordNetOutputs {
        return try src.withUnsafeBufferPointer { buf in
            try extractAll(from: buf.baseAddress!, frames: frames, totalCols: totalCols)
        }
    }

    private static func extract(src: UnsafePointer<Float>,frames: Int,totalCols: Int,range: Range<Int>) throws -> MLMultiArray {
        let cols = range.count
        let arr = try MLMultiArray(
            shape: [NSNumber(value: frames), NSNumber(value: cols)],
            dataType: .float32
        )
        let dst = arr.dataPointer.bindMemory(to: Float.self, capacity: arr.count)
        for f in 0..<frames {
            let srcRow = f * totalCols
            let dstRow = f * cols
            for (j, c) in range.enumerated() {
                dst[dstRow + j] = src[srcRow + c]
            }
        }
        return arr
    }
}

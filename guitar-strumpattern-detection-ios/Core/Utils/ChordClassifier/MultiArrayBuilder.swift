//
//  MultiArrayBuilder.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//

import CoreML
import Foundation

enum MLMultiArrayBuilder {

    static func makeCQTInput(matrix: [[Float]]) throws -> MLMultiArray {
        let frames = matrix.count
        let bins = 252
        let shape: [NSNumber] = [1, NSNumber(value: frames), NSNumber(value: bins)]
        let arr = try MLMultiArray(shape: shape, dataType: .float32)
        let ptr = arr.dataPointer.bindMemory(to: Float.self, capacity: frames * bins)

        for frameIndex in 0..<frames {
            let frame = matrix[frameIndex]
            let copyCount = min(frame.count, bins)
            frame.withUnsafeBufferPointer { buf in
                if let baseAddress = buf.baseAddress {
                    ptr.advanced(by: frameIndex * bins).initialize(from: baseAddress, count: copyCount)
                }
            }
            if copyCount < bins {
                ptr.advanced(by: frameIndex * bins + copyCount)
                    .initialize(repeating: 0, count: bins - copyCount)
            }
        }

        return arr
    }

    static func makeCQTInput(frames: Int, slice: [Float]) throws -> MLMultiArray {
        let bins = 252
        let shape: [NSNumber] = [1, NSNumber(value: frames), NSNumber(value: bins)]
        let arr = try MLMultiArray(shape: shape, dataType: .float32)
        let expected = frames * bins
        let ptr = arr.dataPointer.bindMemory(to: Float.self, capacity: expected)
        let copyCount = min(slice.count, expected)
        slice.withUnsafeBufferPointer { buf in
            ptr.initialize(from: buf.baseAddress!, count: copyCount)
        }
        // Zero-fill any remaining space
        if copyCount < expected {
            (ptr + copyCount).initialize(repeating: 0, count: expected - copyCount)
        }
        return arr
    }
}

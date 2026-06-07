//
//  MultiArrayBuilder.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//

import CoreML
import Foundation

enum MLMultiArrayBuilder {

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

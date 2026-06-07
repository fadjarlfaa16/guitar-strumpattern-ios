//
// Chord.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import CoreML

struct ChordSegment: Identifiable, Equatable {
    let id = UUID()
    let startTime: TimeInterval
    let endTime: TimeInterval
    let label: String
}

struct ChordNetOutputs {
    let triad: MLMultiArray
    let bass: MLMultiArray
    let seventh: MLMultiArray
    let ninth: MLMultiArray
    let eleventh: MLMultiArray
    let thirteenth: MLMultiArray
}

enum ChordNetModelError: Error, LocalizedError {
    case modelNotFound(String)
    case predictionFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "Model not found: \(name)"
        case .predictionFailed(let message):
            return "Prediction failed: \(message)"
        }
    }
}


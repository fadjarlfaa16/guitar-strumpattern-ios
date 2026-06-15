//
//  ChordAdjuster.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 12/06/26.
//

import Foundation

enum ChordAdjuster {
    static func adjust(_ label: String) -> String {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "N" else { return "N" }

        let parts = trimmed.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard let rootPart = parts.first, !rootPart.isEmpty else { return trimmed }

        let root = String(rootPart)
        guard parts.count == 2 else { return root }

        let quality = String(parts[1])

        if quality.hasPrefix("min") {
            return "\(root)m"
        }

        return root
    }

    static func adjust(_ labels: [String]) -> [String] {
        labels.map(adjust)
    }
}

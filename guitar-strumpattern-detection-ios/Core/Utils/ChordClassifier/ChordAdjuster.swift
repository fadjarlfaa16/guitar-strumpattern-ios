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

        if quality.hasPrefix("min7") {
            return "\(root)m7"
        }
        if quality.hasPrefix("maj7") {
            return "\(root)maj7"
        }
        if quality == "7" || quality.hasPrefix("9") || quality.hasPrefix("11") || quality.hasPrefix("13") {
            return "\(root)7"
        }
        if quality.hasPrefix("min") {
            return "\(root)m"
        }
        if quality.hasPrefix("maj")
            || quality.hasPrefix("sus")
            || quality.hasPrefix("dim")
            || quality.hasPrefix("aug") {
            return root
        }

        return root
    }

    static func adjust(_ labels: [String]) -> [String] {
        labels.map(adjust)
    }
}

//
//  ChordMapping.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//

import Foundation

// MARK: - ChordEntry


struct ChordEntry {
    let label: String
    let triad: Int
    let bass: Int
    let seventh: Int
    let ninth: Int
    let eleventh: Int
    let thirteenth: Int
}

final class ChordMapping {
    let entries: [ChordEntry]

    init(entries: [ChordEntry]) {
        self.entries = entries
    }

    // Loads chord mapping from chord_mapping_submission.json
    static func load() throws -> ChordMapping {
        guard let url = Bundle.main.url(forResource: "chord_mapping_submission", withExtension: "json")
                     ?? Bundle.main.url(forResource: "chord_mapping_submission", withExtension: "json", subdirectory: "Core/Utils/ChordClassifier") else {
            throw NSError(domain: "ChordMapping", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "chord_mapping_submission.json not found in bundle."])
        }

        let text = try String(contentsOf: url, encoding: .utf8)

        // Find first non-empty line and parse it as JSON
        var jsonData: Data?
        for line in text.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                jsonData = trimmed.data(using: .utf8)
                break
            }
        }

        guard let data = jsonData else {
            throw NSError(domain: "ChordMapping", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "chord_mapping_submission.json is empty."])
        }

        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let labels = obj["labels"] as? [String],
              let arrays = obj["arrays"] as? [[Int]] else {
            throw NSError(domain: "ChordMapping", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid chord mapping JSON format. Expected {\"labels\":[...], \"arrays\":[[...],...]}"])
        }

        var entries: [ChordEntry] = []
        entries.reserveCapacity(labels.count)
        for (i, label) in labels.enumerated() {
            guard i < arrays.count, arrays[i].count == 6 else { continue }
            let a = arrays[i]
            entries.append(ChordEntry(
                label:       label,
                triad:       a[0],
                bass:        a[1],
                seventh:     a[2],
                ninth:       a[3],
                eleventh:    a[4],
                thirteenth:  a[5]
            ))
        }

        return ChordMapping(entries: entries)
    }
}

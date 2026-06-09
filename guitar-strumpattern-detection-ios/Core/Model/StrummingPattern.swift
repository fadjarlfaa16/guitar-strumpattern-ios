//
//  StrummingPattern.swift
//  guitar-strumpattern-detection-ios
//

import Foundation

struct StrummingPattern: Identifiable, Equatable, Sendable {
    let id: UUID
    let notation: String

    init(id: UUID = UUID(), label: String) {
        self.id = id
        self.notation = label
    }

    /// Parses notation like "DUUD - DDUUU" into playable beats.
    var beats: [StrumBeat] {
        notation
            .uppercased()
            .filter { !$0.isWhitespace && $0 != "-" }
            .compactMap { char -> StrumBeat? in
                switch char {
                case "D": return .down
                case "U": return .up
                case "N": return .noStrum
                default: return nil
                }
            }
    }
}

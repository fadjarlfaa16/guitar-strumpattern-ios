//
//  StrummingPattern.swift
//  guitar-strumpattern-detection-ios
//

import Foundation

struct StrummingPattern: Identifiable, Equatable, Sendable {
    let id: UUID
    let notation: String
    let libraryID: Int?
    let matchScore: Double?

    init(id: UUID = UUID(), label: String, libraryID: Int? = nil, matchScore: Double? = nil) {
        self.id = id
        self.notation = label
        self.libraryID = libraryID
        self.matchScore = matchScore
    }

    /// Parses notation like "DUUD - DDUUU" into playable beats.
    var beats: [StrumBeat] {
        notation
            .uppercased()
            .split(whereSeparator: \.isWhitespace)
            .flatMap { token in
                token.compactMap { char -> StrumBeat? in
                    switch char {
                    case "D": return .down
                    case "U": return .up
                    case "N", "-", "–", "—": return .noStrum
                    default: return nil
                    }
                }
            }
    }
}

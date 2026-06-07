//
//  StrummingPattern.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//
import Foundation

struct StrummingPattern: Identifiable {
    let id: UUID
    let notation: String

    init(id: UUID = UUID(), notation: String) {
        self.id = id
        self.notation = notation
    }
}

extension StrummingPattern {
    static let samples: [StrummingPattern] = [StrummingPattern(notation: "DUUD - DDUUU"),StrummingPattern(notation: "DUUD - DUUD")]
}

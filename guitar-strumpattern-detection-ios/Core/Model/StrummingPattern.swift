//
//  StrummingPattern.swift
//  guitar-strumpattern-detection-ios
//

import Foundation

struct StrummingPattern: Identifiable, Equatable, Sendable {
    let id: UUID
    let label: String

    init(id: UUID = UUID(), label: String) {
        self.id = id
        self.label = label
    }
}

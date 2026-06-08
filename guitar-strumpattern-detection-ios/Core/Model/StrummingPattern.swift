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
}

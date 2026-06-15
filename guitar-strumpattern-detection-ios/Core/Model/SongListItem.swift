//
//  SongListItem.swift
//  guitar-strumpattern-detection-ios
//

import Foundation

struct SongListItem: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    let bpm: Int
    let timeSignature: String
    let title: String
    let artist: String
    let scorePercent: Int

    var displayTitle: String {title}

    init(
        id: UUID = UUID(),
        bpm: Int,
        timeSignature: String,
        title: String,
        artist: String,
        scorePercent: Int
    ) {
        self.id = id
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.title = title
        self.artist = artist
        self.scorePercent = scorePercent
    }
}

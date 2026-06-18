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
    let sandboxFileName: String?


    var displayTitle: String {
        title.isEmpty ? "Untitled" : title
    }

    var isAnalyzed: Bool {
        bpm > 0 && timeSignature != "-"
    }
 
    init(
        id: UUID = UUID(),
        bpm: Int,
        timeSignature: String,
        title: String,
        artist: String,
        scorePercent: Int,
        sandboxFileName: String? = nil
    ) {
        self.id = id
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.title = title
        self.artist = artist
        self.scorePercent = scorePercent
        self.sandboxFileName = sandboxFileName
    }
}
struct StoredChordSegment: Codable, Equatable, Hashable {
    let startTime: TimeInterval
    let endTime: TimeInterval
    let label: String
}

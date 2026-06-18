//
//  Song.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//


import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    var title: String
    var artist: String?
    var sandboxFileName: String
    var duration: TimeInterval
    var addedAt: Date
    var bpm: Int?
    var timeSignature: String?
    var chordSegments: [StoredChordSegment]?

    var isAnalysed: Bool { chordSegments != nil }

    init(
        id: UUID = UUID(),
        title: String,
        artist: String? = nil,
        sandboxFileName: String,
        duration: TimeInterval = 0,
        addedAt: Date = .now,
        bpm: Int? = nil,
        timeSignature: String? = nil,
        chordChangeRate: Double? = nil,
        chordSegments: [StoredChordSegment]? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.sandboxFileName = sandboxFileName
        self.duration = duration
        self.addedAt = addedAt
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.chordSegments = chordSegments
    }
}



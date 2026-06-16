//
//  SongInfo.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//

import Foundation

struct SongInfo: Sendable, Equatable {
    let bpm: Int
    let timeSignature: String
    let displayTitle: String
    let displayArtist: String
}

extension SongInfo {
    static let sample = SongInfo(
        bpm: 120,
        timeSignature: "4/4",
        displayTitle: "Twinkle Twinkle Little Star",
        displayArtist: ""
    )
}

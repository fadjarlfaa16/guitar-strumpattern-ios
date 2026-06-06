//
//  SongInfo.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//



struct SongInfo: Sendable, Equatable {
    let bpm: Int
    let timeSignature: String
    let displayTitle: String
}
//
//  PatternNavigationDestination.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


import SwiftUI

struct PatternNavigationDestination: View {
    let selectedPattern: StrummingPattern?
    let chordSegments: [StoredChordSegment]?
    let bpm: Int
    let rhythm: String
    let audioURL: URL?

    var body: some View {
        let beats = selectedPattern?.beats ?? []

        let chords = chordSegments?.map {
            ChordSegment(
                startTime: $0.startTime,
                endTime: $0.endTime,
                label: $0.label
            )
        } ?? ChordGroup.sampleSegments

        PlayingSessionView(
            chords: chords,
            pattern: beats.isEmpty
                ? ChordGroup.samplePattern
                : beats,
            bpm: bpm,
            timeSignature: rhythm,
            audioURL: audioURL,
            patternNotation: selectedPattern?.notation
        )
    }
}
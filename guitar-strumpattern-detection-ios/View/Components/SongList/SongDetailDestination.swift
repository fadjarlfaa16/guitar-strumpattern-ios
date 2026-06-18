//
//  SongDetailDestination.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


//
// SongDetailDestination.swift
//

import SwiftUI

struct SongDetailDestination: View {
    let songID: UUID

    var body: some View {
        if let stored = SongLibraryStore.shared.load().first(where: { $0.id == songID }) {

            if let bpm = stored.bpm,
               bpm > 0,
               let timeSignature = stored.timeSignature,
               let chordSegments = stored.chordSegments,
               !chordSegments.isEmpty {

                let audioURL = SongLibraryStore.audioDirectory
                    .appendingPathComponent(stored.sandboxFileName)

                let recommendedPatterns = StrumPatternLibrary.recommendations(
                    bpm: bpm,
                    timeSignature: timeSignature,
                    chordSegments: chordSegments
                )

                ChooseStrummingPatternView(
                    bpm: bpm,
                    rhythm: timeSignature,
                    patterns: recommendedPatterns,
                    chordSegments: chordSegments,
                    audioURL: audioURL
                )

            } else {
                ContentUnavailableView(
                    "Analyze Song First",
                    systemImage: "waveform.circle"
                )
            }

        } else {
            ContentUnavailableView(
                "Song Not Found",
                systemImage: "music.note.list"
            )
        }
    }
}


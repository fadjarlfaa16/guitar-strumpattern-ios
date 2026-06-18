//
//  MusicPlayer.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import SwiftUI

struct MusicPlayer: View {
    var songTitle: String = "Unknown Song"
    var bpm: Int = 120
    var timeSignature: String = "4/4"

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "play.circle.fill")
                .foregroundColor(.brandColorPrimaryPurple)
                .font(.system(size: 33))

            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Image(systemName: "stopwatch.fill")
                            .foregroundColor(.brandColorAccentGreen)
                        Text("= \(bpm) bpm")
                            .foregroundColor(.brandColorAccentGreen)
                    }
                    HStack {
                        Image(systemName: "metronome.fill")
                            .foregroundColor(.brandColorAccentGreen)
                        Text("= \(timeSignature)")
                            .foregroundColor(.brandColorAccentGreen)
                    }
                }
                Text(songTitle)
                    .foregroundColor(.brandColorAccentGreen)
            }
        }
    }
}

#Preview {
    MusicPlayer()
        .background(Color.backgroundPrimaryBlack)
}

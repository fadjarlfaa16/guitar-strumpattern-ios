//
//  MusicPlayer.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//
import SwiftUI

struct MusicPlayer: View {
    var bpm: Int
    var rhythm: String
    var title: String

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
                        Text("= \(rhythm)")
                            .foregroundColor(.brandColorAccentGreen)
                    }
                }
                Text(title)
                    .foregroundColor(.brandColorAccentGreen)
                    .lineLimit(1)
                
            }
        }
    }
}

#Preview {
    MusicPlayer(bpm: 60, rhythm: "4/4", title: "Twinkle Twinkle Little")
}


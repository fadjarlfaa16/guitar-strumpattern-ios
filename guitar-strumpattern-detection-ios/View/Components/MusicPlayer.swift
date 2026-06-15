//
//  MusicPlayer.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//
import SwiftUI

struct MusicPlayer: View {
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
                        Text("= 120 bpm")
                            .foregroundColor(.brandColorAccentGreen)
                    }
                    HStack {
                        Image(systemName: "metronome.fill")
                            .foregroundColor(.brandColorAccentGreen)
                        Text("= 4/4")
                            .foregroundColor(.brandColorAccentGreen)
                    }
                }
                Text("Niki - Backburner")
                    .foregroundColor(.brandColorAccentGreen)
                
            }
        }
    }
}

#Preview {
    MusicPlayer()
}

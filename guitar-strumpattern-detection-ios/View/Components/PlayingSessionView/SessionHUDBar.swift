//
//  SessionHUDBar 2.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 18/06/26.
//


//
//  SessionHUDBar.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

struct SessionHUDBar: View {
    let bpm: Int
    let timeSignature: String
    let patternNotation: String
    let isFirstTime: Bool

    let onSkip: (() -> Void)?

    var body: some View {
        HStack {
            if isFirstTime {
                Spacer()
            }
            Image(systemName: "metronome.fill")
                .foregroundStyle(.textPrimaryWhite)
                .font(AppFont.bodyBold)
            Text("\(bpm) BPM")
                    .font(AppFont.bodyBold)
                .foregroundStyle(.textPrimaryWhite)
            Text("·").foregroundStyle(.textPrimaryWhite.opacity(0.5))
            Text(timeSignature)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.brandColorAccentGreen.opacity(0.8))
            Text("·").foregroundStyle(.brandColorAccentGreen.opacity(0.5))
            Text(patternNotation)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.textPrimaryWhite.opacity(0.85))
                .lineLimit(1)

            if isFirstTime {
                Spacer()
                SecondaryTextButton(
                    title: "Skip",
                    color: .textPrimaryWhite,
                    font: .system(size: 13, weight: .semibold)
                ) {
                    onSkip?()
                }
            }
        }
    }
}

#Preview {
    SessionHUDBar(
        bpm: 120,
        timeSignature: "4/4",
        patternNotation: "DUDU",
        isFirstTime: true,
        onSkip: {}
    )
}

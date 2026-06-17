//
//  FinishedOverlay.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

struct FinishedOverlay: View {

    let isFirstTime: Bool

    let onReplay: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            VStack(spacing: 32) {
                Text("PATTERN COMPLETE!")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .shadow(color: .brandColorPrimaryPurple.opacity(0.6), radius: 20)

                HStack(spacing: 24) {
                    Button {
                        onReplay()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 28, weight: .black))

                            Text("REPLAY")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                        }
                        .foregroundStyle(.white)
                        .frame(width: 160)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .brandColorPrimaryPurple,
                                            Color(hue: 0.75, saturation: 0.8, brightness: 0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .brandColorPrimaryPurple.opacity(0.55), radius: 14)
                    }
                    .buttonStyle(StrumButtonStyle())

                    Button {
                        onContinue()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .bold))

                            Text("CONTINUE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundStyle(.brandColorAccentGreen)
                        .frame(width: 140)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.brandColorAccentGreen.opacity(0.1))
                                .strokeBorder(
                                    .brandColorAccentGreen.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(StrumButtonStyle())
                }
            }
            .padding(40)
        }
    }
}

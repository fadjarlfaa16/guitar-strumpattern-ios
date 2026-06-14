//
//  CalibratePlaySection.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct CalibratePlaySection: View {
    @ObservedObject var receiver: WatchReceiver
    @ObservedObject var chordVM: RealTimeChordViewModel
    let strumCount: Int
    let lastConfirmedStrum: String?
    let strumScale: CGFloat
    let flashOpacity: Double

    var body: some View {
        VStack(spacing: Spacing.lg) {
            strumCard
            chordCard
            statsRow
        }
    }

    private var strumCard: some View {
        VStack(spacing: Spacing.md) {
            Text("Arah Strum")
                .font(AppFont.caption1Regular)
                .foregroundColor(.textSecondary)

            Text(strumLabel)
                .font(AppFont.largeTitleBold)
                .foregroundColor(strumColor)
                .scaleEffect(strumScale)
                .animation(.spring(response: 0.1, dampingFraction: 0.4), value: strumScale)

            if chordVM.isListening {
                Label("Motion + Audio confirmed", systemImage: "waveform.badge.checkmark")
                    .font(AppFont.caption1Regular)
                    .foregroundStyle(.brandColorAccentGreen)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(
            ZStack {
                Color.bgCard
                Color.brandColorAccentGreen.opacity(flashOpacity)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private var chordCard: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Chord Terdeteksi")
                    .font(AppFont.caption1Regular)
                    .foregroundColor(.textSecondary)
                Spacer()
                if chordVM.isAnalyzing {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            Text(chordVM.currentChord)
                .font(AppFont.largeTitleBold)
                .foregroundColor(.textPrimary)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            if let error = chordVM.errorMessage {
                Text(error)
                    .font(AppFont.caption1Regular)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private var statsRow: some View {
        HStack(spacing: Spacing.md) {
            statBox(title: "Strum", value: "\(strumCount)")
            if let last = lastConfirmedStrum {
                statBox(title: "Terakhir", value: last == "Down" ? "↓ Down" : "↑ Up")
            }
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.caption1Regular)
                .foregroundColor(.textSecondary)
            Text(value)
                .font(AppFont.headlineSemibold.monospacedDigit())
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }

    private var strumLabel: String {
        switch receiver.lastStrum {
        case "Down": return "DOWN"
        case "Up": return "UP"
        default: return "—"
        }
    }

    private var strumColor: Color {
        switch receiver.lastStrum {
        case "Down": return .brandColorPrimaryPurple
        case "Up": return .brandColorAccentGreen
        default: return .textSecondary
        }
    }
}

//
//  CalibrateAudioSettingsCard.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct CalibrateAudioSettingsCard: View {
    @ObservedObject var receiver: WatchReceiver
    @ObservedObject var audioMonitor: AudioMonitor
    let isCalibrated: Bool
    let isSoundGateOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Pengaturan Audio (Mic)")
                .font(AppFont.headlineSemibold)
                .foregroundColor(.textPrimary)

            HStack {
                Text("Volume:")
                    .font(AppFont.caption1Regular)
                    .foregroundColor(Color.textSecondary)
                ProgressView(
                    value: max(0, Double(audioMonitor.currentDecibels + 80)),
                    total: 80
                )
                .tint(gateIndicatorColor)
                Text("\(String(format: "%.1f", audioMonitor.currentDecibels)) dB")
                    .font(AppFont.caption1Regular.monospacedDigit())
                    .foregroundColor(.textPrimary)
                    .frame(width: 60, alignment: .trailing)
            }

            Divider().overlay(Color.textSecondary.opacity(0.3))

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Batas Hening (Abaikan bising)")
                        .font(AppFont.caption1Regular)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", receiver.micBaseThreshold)) dB")
                        .font(AppFont.caption1Regular.bold())
                        .foregroundColor(.textPrimary)
                }
                Slider(value: $receiver.micBaseThreshold, in: -70...(-20), step: 1.0)
                    .tint(.brandColorPrimaryPurple)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Sensitivitas Petikan (Lonjakan)")
                        .font(AppFont.caption1Regular)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("+\(String(format: "%.1f", receiver.micSpikeThreshold)) dB")
                        .font(AppFont.caption1Regular.bold())
                        .foregroundColor(.textPrimary)
                }
                Slider(value: $receiver.micSpikeThreshold, in: 1.0...15.0, step: 0.5)
                    .tint(.brandColorAccentGreen)
                Text("Kiri: Akustik lembut | Kanan: Strumming keras")
                    .font(AppFont.caption2Regular)
                    .foregroundColor(.textSecondary)
            }

            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(gateIndicatorColor)
                    .frame(width: 8, height: 8)
                Text(gateIndicatorText)
                    .font(AppFont.caption2Regular)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private var gateIndicatorColor: Color {
        if isCalibrated {
            return isSoundGateOpen ? .brandColorAccentGreen : .textSecondary
        }
        return audioMonitor.isGateOpen ? .brandColorAccentGreen : .textSecondary
    }

    private var gateIndicatorText: String {
        if isCalibrated {
            return isSoundGateOpen
                ? "Petikan terdeteksi (fase main)"
                : "Menunggu petikan (fase main)"
        }
        return audioMonitor.isGateOpen
            ? "Petikan terdeteksi (kalibrasi)"
            : "Menunggu petikan (kalibrasi)"
    }
}

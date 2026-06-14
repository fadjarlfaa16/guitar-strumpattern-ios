//
//  CalibrateStrumSection.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct CalibrateStrumSection: View {
    @ObservedObject var receiver: WatchReceiver
    let isCalibrated: Bool
    let onStartCalibration: () -> Void
    let onRecalibrate: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: "applewatch")
                    .foregroundStyle(.brandColorPrimaryPurple)
                Text("Kalibrasi Strum")
                    .font(AppFont.headlineSemibold)
                    .foregroundColor(.textPrimary)
                Spacer()
                if isCalibrated {
                    Label("Selesai", systemImage: "checkmark.circle.fill")
                        .font(AppFont.caption1Regular.bold())
                        .foregroundStyle(.brandColorAccentGreen)
                }
            }

            if receiver.isCalibrating {
                calibratingContent
            } else if isCalibrated {
                calibratedSummary
            } else {
                idleCalibrationContent
            }
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private var idleCalibrationContent: some View {
        VStack(spacing: Spacing.md) {
            instructionRow(icon: "arrow.down", color: .brandColorPrimaryPurple, text: "5× Downstroke kuat")
            instructionRow(icon: "arrow.up", color: .brandColorAccentGreen, text: "5× Upstroke kuat")
            instructionRow(icon: "mic.fill", color: .brandColorSecondaryPink, text: "Harus terdengar suara gitar")

            Text("Pastikan Apple Watch terpasang dan app Watch aktif.")
                .font(AppFont.caption1Regular)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            CustomButton(title: "Mulai Kalibrasi", action: onStartCalibration)
        }
    }

    private var calibratingContent: some View {
        VStack(spacing: Spacing.md) {
            Text(receiver.calibrationStatusText)
                .font(AppFont.title3Bold)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            ProgressView(
                value: Double(receiver.recordedSamplesCount),
                total: Double(receiver.targetSamples)
            )
            .tint(.brandColorPrimaryPurple)

            Text("\(receiver.recordedSamplesCount) / \(receiver.targetSamples)")
                .font(AppFont.title3Bold.monospacedDigit())
                .foregroundColor(.textPrimary)

            Text("Gerakan Watch + suara gitar harus terdeteksi bersamaan")
                .font(AppFont.caption1Regular)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var calibratedSummary: some View {
        VStack(spacing: Spacing.md) {
            Text(receiver.calibrationStatusText)
                .font(AppFont.bodyRegular)
                .foregroundColor(.textSecondary)

            Button("Kalibrasi Ulang", action: onRecalibrate)
                .font(AppFont.bodyRegular)
                .foregroundColor(.accentPurple)
        }
    }

    private func instructionRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(AppFont.bodyRegular)
                .foregroundColor(.textPrimary)
            Spacer()
        }
    }
}

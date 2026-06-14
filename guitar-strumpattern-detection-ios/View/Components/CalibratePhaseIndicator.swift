//
//  CalibratePhaseIndicator.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct CalibratePhaseIndicator: View {
    let isCalibrated: Bool

    var body: some View {
        HStack(spacing: 0) {
            phaseStep(number: 1, title: "Kalibrasi", active: !isCalibrated, done: isCalibrated)
            connector(filled: isCalibrated)
            phaseStep(number: 2, title: "Main", active: isCalibrated, done: false)
        }
        .padding(.horizontal, Spacing.xs)
    }

    private func phaseStep(number: Int, title: String, active: Bool, done: Bool) -> some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(done ? Color.brandColorAccentGreen : (active ? Color.brandColorPrimaryPurple : Color.textSecondary.opacity(0.25)))
                    .frame(width: 32, height: 32)
                if done {
                    Image(systemName: "checkmark")
                        .font(AppFont.caption1Regular.bold())
                        .foregroundColor(.textPrimary)
                } else {
                    Text("\(number)")
                        .font(AppFont.caption1Regular.bold())
                        .foregroundColor(active ? .textPrimary : .textSecondary)
                }
            }
            Text(title)
                .font(AppFont.caption1Regular)
                .foregroundColor(active || done ? .textPrimary : .textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func connector(filled: Bool) -> some View {
        Rectangle()
            .fill(filled ? Color.brandColorAccentGreen : Color.textSecondary.opacity(0.25))
            .frame(height: 2)
            .frame(maxWidth: 40)
            .padding(.bottom, 18)
    }
}

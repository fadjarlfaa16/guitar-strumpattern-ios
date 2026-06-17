//
//  Buttons.swift
//  guitar-strumpattern-detection-ios
//
//  Shared button components used across the app.
//

import SwiftUI

// MARK: - Primary Button
struct CustomButton: View {
    let title: String
    var tint: Color = .brandColorPrimaryPurple2
    var isDisabled: Bool = false
    var action: (() -> Void) = {}

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(AppFont.headlineSemibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
        }
        .disabled(isDisabled)
        .tint(tint)
        .buttonStyle(.glassProminent)
    }
}

// MARK: - Secondary Text Button

struct SecondaryTextButton: View {
    let title: String
    var color: Color = .brandColorPrimaryPurple
    var font: Font = AppFont.bodyRegular
    var action: (() -> Void) = {}

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(font)
                .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        CustomButton(title: "Next") {}
        CustomButton(title: "Confirm & Continue", tint: .brandColorAccentGreen) {}
        SecondaryTextButton(title: "Skip for now") {}
        SecondaryTextButton(title: "Reset", color: .brandColorAccentGreen) {}
    }
    .padding(Spacing.xl)
    .background(Color.backgroundPrimaryBlack)
}

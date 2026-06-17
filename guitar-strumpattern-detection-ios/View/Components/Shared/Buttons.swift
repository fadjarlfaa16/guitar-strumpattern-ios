//
//  Buttons.swift
//  guitar-strumpattern-detection-ios
//
//  Shared button components used across the app.
//

import SwiftUI

enum CustomButtonStyle {
    case glass
    case capsule
}
// MARK: - Primary Button
struct CustomButton: View {
    let title: String

    var tint: Color = .brandColorPrimaryPurple2
    var textColor: Color = .white
    var isDisabled: Bool = false
    var style: CustomButtonStyle = .glass

    var action: (() -> Void) = {}

    var body: some View {

        switch style {

        case .glass:
            Button {
                action()
            } label: {
                Text(title)
                    .font(AppFont.headlineSemibold)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
            }
            .disabled(isDisabled)
            .tint(tint)
            .buttonStyle(.glassProminent)

        case .capsule:
            Button {
                action()
            } label: {
                Text(title)
                    .font(AppFont.headlineSemibold)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg)
                    .background(
                        Capsule()
                            .fill(tint)
                    )
            }
            .disabled(isDisabled)
            .buttonStyle(.plain)
        }
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

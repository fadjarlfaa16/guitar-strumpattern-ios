//
//  StrummingPatternButton.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Strumming Pattern Button
struct StrummingPatternButton: View {
    let label: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            Text(label)
                .font(AppFont.heading(16))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(
                    Capsule()
                        .fill(Color.accentPurple)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        StrummingPatternButton(label: "DUUD - DDUUU")
        StrummingPatternButton(label: "DUUD - DDUUU")
    }
    .padding(.horizontal, Spacing.xl)
    .background(Color.bgPrimary)
}

//
//  StrummingPatternButton.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Strumming Pattern Button
struct StrummingPatternButton: View {
    let label: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            Text(label)
                .font(AppFont.headlineSemibold)
                .foregroundColor(isSelected ? .black : .textPrimaryWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentGreen : Color.brandColorPrimaryPurple2)
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
    .background(Color.backgroundPrimaryBlack)
}

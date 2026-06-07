//
//  StrummingPatternButton.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//


// StrummingPatternButtonView.swift
// Komponen satu baris tombol strumming pattern

import SwiftUI

// MARK: - Strumming Pattern Button
struct StrummingPatternButton: View {
    let pattern: StrummingPattern
    let isSelected: Bool
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            PatternButtonLabel(notation: pattern.notation, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pattern Button Label
/// Visual dari tombol pattern: pill shape dengan teks notasi
struct PatternButtonLabel: View {
    let notation: String
    let isSelected: Bool

    var body: some View {
        Text(notation)
            .font(AppFont.BodyRegular)
            .foregroundColor(.textPrimaryWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.nonclickable)
                    .fill(isSelected ? Color.brandColorAccentGreen : Color.brandColorPrimaryPurple)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.nonclickable)
                    .strokeBorder(
                        isSelected ? Color.brandColorAccentGreen : Color.clear,
                        lineWidth: 2
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        StrummingPatternButton(pattern: .samples[0], isSelected: false)
        StrummingPatternButton(pattern: .samples[1], isSelected: true)
    }
    .padding()
    .background(Color.backgroundPrimaryBlack)
}

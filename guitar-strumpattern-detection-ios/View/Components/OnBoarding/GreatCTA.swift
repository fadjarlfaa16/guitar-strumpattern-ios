//
//  GreatCTAView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//


// GreatCTAView.swift
// Komponen CTA bawah: tombol "Add Song" + link "Skip for now"

import SwiftUI

// MARK: - Great CTA View
struct GreatCTA: View {
    var onAddSong: (() -> Void)? = nil
    var onSkip: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            AddSongButton(action: onAddSong)
            SkipButton(action: onSkip)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Add Song Button
struct AddSongButton: View {
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Text("Add Song")
                .font(AppFont.headlineSemibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    Capsule()
                        .fill(Color.brandColorPrimaryPurple)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Skip Button
struct SkipButton: View {
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Text("Skip for now")
                .font(AppFont.caption1Regular)
                .foregroundColor(Color.brandColorPrimaryPurple)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    GreatCTA()
        .background(Color.backgroundPrimaryBlack)
}

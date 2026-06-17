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
            CustomButton(title: "Add Song") { onAddSong?() }
            SecondaryTextButton(title: "Skip for now") { onSkip?() }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Preview
#Preview {
    GreatCTA()
        .background(Color.backgroundPrimaryBlack)
}

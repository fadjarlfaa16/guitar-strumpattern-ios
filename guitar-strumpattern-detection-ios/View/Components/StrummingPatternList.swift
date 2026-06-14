//
//  StrummingPatternListView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//


// StrummingPatternListView.swift
// Komponen daftar semua tombol strumming pattern

import SwiftUI

// MARK: - Strumming Pattern List View
struct StrummingPatternList: View {
    let patterns: [StrummingPattern]
    @Binding var selectedPatternID: UUID?
    var onPatternTap: ((StrummingPattern) -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            ForEach(patterns) { pattern in
                StrummingPatternButton(
                    label: pattern.notation,
                    isSelected: selectedPatternID == pattern.id
                ) {
                    selectedPatternID = pattern.id
                    onPatternTap?(pattern)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedID: UUID? = nil

    StrummingPatternList(
        patterns: Array(StrumPatternLibrary.allPatterns().prefix(4)),
        selectedPatternID: $selectedID
    )
    .background(Color.backgroundPrimaryBlack)
}

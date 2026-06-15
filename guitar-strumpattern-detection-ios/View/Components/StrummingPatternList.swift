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
    let bpm: Int
    let rhythm: String
    let patterns: [StrummingPattern]
    @Binding var selectedPatternID: UUID?
    var onPatternTap: ((StrummingPattern) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.lg) {
                MusicPlayer()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.sm)
    
            }
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
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedID: UUID? = nil
    StrummingPatternList(
        bpm: 120,
        rhythm: "4/4",
        patterns: Array(StrumPatternLibrary.allPatterns().prefix(4)),
        selectedPatternID: $selectedID
    )
    .background(Color.backgroundPrimaryBlack)
}

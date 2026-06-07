//
//  ChooseStrummingPatternView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//


// ChooseStrummingPatternView.swift
// Screen utama yang menyatukan semua component

import SwiftUI

// MARK: - Choose Strumming Pattern Screen
struct ChooseStrummingPatternView: View {
    // State
    @State private var selectedPatternID: UUID? = nil
    private let song: SongInfo
    private let patterns: [StrummingPattern] = StrummingPattern.samples
    init(song: SongInfo = .sample) {
        self.song = song
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HeroHeader()

                    SongInfoBar(song: song) {
                    }
                    StrummingPatternList(
                        patterns: patterns,
                        selectedPatternID: $selectedPatternID
                    )

                    Spacer(minLength: Spacing.xxl)
                }
            }
        }

        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ChooseStrummingPatternView(song: SongInfo .sample)
    }
}

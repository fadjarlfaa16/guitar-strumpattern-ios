// GreatPageView.swift
// Screen utama Great Page — rakitan semua component

import SwiftUI

// MARK: - Great Page View
struct GreatPageView: View {
    @State private var navigateToSongList = false
    @AppStorage("appState") private var navRoot: NavRoot = .onboarding
    @Environment(AppState.self) private var appState
    var songListSample: [SongListItem] = []

    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Header: blob hijau outline + teks Great!
                GreatHeader()

                Spacer()

                // 2. Ilustrasi tengah: music note + file upload
                GreatIllustration()

                Spacer()

                // 3. Blob ungu dekoratif kanan bawah
                HStack {
                    Spacer()
                    GreatBottomBlob()
                        .offset(x: 60, y: 20)
                }

                // 4. CTA: Add Song + Skip for now
                GreatCTA(
                    onAddSong: {
                        appState.savedSongs.append(contentsOf: SongListItem.samples)
                        appState.isFirstTime = false
                        navRoot = .songList
                    },
                    onSkip: {
                        appState.isFirstTime = false
                        navRoot = .songList
                    }
                )
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GreatPageView()
            .environment(AppState())
    }
}

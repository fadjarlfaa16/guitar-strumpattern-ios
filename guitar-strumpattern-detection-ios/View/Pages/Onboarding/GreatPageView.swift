// GreatPageView.swift
// Screen utama Great Page — rakitan semua component

import SwiftUI

// MARK: - Great Page View
struct GreatPageView: View {
    @State private var navigateToSongList = false
    @AppStorage("navRoot") private var navRoot: NavRoot = .onboarding
    var songListSample: [SongListItem] = []
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true

    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

            // Background Wavy Lines
            GreatBackgroundLines()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Header: blob hijau outline + teks Great!
                HeroHeader {
                    Text("Great!")
                        .font(AppFont.largeTitleBold)
                        .foregroundColor(.textPrimaryWhite)

                    Text("""
                    Before you go, you need to add a song from your local library. Make sure it's in MP3, WAV, or M4A.
                    """)
                    .font(AppFont.bodyRegular)
                    .foregroundColor(.textPrimaryWhite.opacity(0.7))
                }

                Spacer()

                // 2. Ilustrasi tengah: music note + file upload
                GreatIllustration()

                Spacer()
                
                // 4. CTA: Add Song + Skip for now
                GreatCTA(
                    onAddSong: {
                        navRoot = .songList
                        isFirstLaunch = false
                    },
                    onSkip: {
                        isFirstLaunch = false
                        navRoot = .songList
                        
                    }
                )
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Decorative Background Lines
// MARK: - Decorative Background Lines
struct GreatBackgroundLines: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                // Green Line — valley dari kiri atas, melengkung sedikit ke bawah, keluar kanan
                Path { path in
                    path.move(to: CGPoint(x: -20, y: height * 0.08))
                    path.addCurve(
                        to: CGPoint(x: width + 20, y: height * 0.22),
                        control1: CGPoint(x: width * 0.28, y: height * 0.40),
                        control2: CGPoint(x: width * 0.62, y: height * 0.40)
                    )
                }
                .stroke(
                    Color.brandColorAccentGreen.opacity(0.2),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                )

                // Purple Line — dari kanan (~73%), sweep lembut ke bawah kiri
                Path { path in
                    path.move(to: CGPoint(x: width + 20, y: height * 0.73))
                    path.addCurve(
                        to: CGPoint(x: -20, y: height * 0.93),
                        control1: CGPoint(x: width * 0.68, y: height * 0.82),
                        control2: CGPoint(x: width * 0.28, y: height * 0.78)
                    )
                }
                .stroke(
                    Color.brandColorSecondaryPink.opacity(0.20),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}
// MARK: - Preview
#Preview {
    NavigationStack {
        GreatPageView()
    }
}

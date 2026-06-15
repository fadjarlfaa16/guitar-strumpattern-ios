//
//  ChooseStrummingPatternView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Choose Strumming Pattern View
struct ChooseStrummingPatternView: View {
    let bpm: Int
    let rhythm: String
    let patterns: [StrummingPattern]
    var chordSegments: [StoredChordSegment]? = nil
    @AppStorage("isFirstLaunch") private var isFirstTime: Bool = true
    var audioURL: URL?
    var onPatternSelected: ((StrummingPattern) -> Void)? = nil
    @State private var selectedPatternID: UUID? = nil
    @State private var selectedPattern: StrummingPattern? = nil
    @State private var navigateToSession = false

    var body: some View {
        ZStack {
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    headerSection
                        .padding(.vertical, Spacing.xs)
                    patternList
                    .padding(.top, Spacing.md)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.md)

            }
        }
        .navigationDestination(isPresented: $navigateToSession) {
            let beats = selectedPattern?.beats ?? []
            let chords = chordSegments?.map { segment in
                ChordSegment(
                    startTime: segment.startTime,
                    endTime: segment.endTime,
                    label: segment.label
                )
            } ?? ChordGroup.sampleSegments
            
            PlayingSessionView(
                chords: chords,
                pattern: beats.isEmpty ? ChordGroup.samplePattern : beats,
                bpm: bpm,
                timeSignature: rhythm,
                audioURL: audioURL,
                patternNotation: selectedPattern?.notation
            )
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Choose Your Preferred Strumming Pattern")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text("These patterns are choosed based on the song's BPM and rhythm")
                .font(AppFont.bodyRegular)
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: Spacing.lg) {
                metadataLabel("BPM: \(bpm)")
                metadataLabel("Rhythm: \(rhythm)")
            }
        }
    }

   

    // MARK: - Pattern List
    private var patternList: some View {
        StrummingPatternList(
            bpm: bpm, rhythm: rhythm,
            patterns: patterns,
            selectedPatternID: $selectedPatternID,
            onPatternTap: selectPattern
        )

        .padding(.top, Spacing.sm)
        .onAppear {
            selectedPatternID = nil
        }
    }

    private func selectPattern(_ pattern: StrummingPattern) {
        selectedPatternID = pattern.id
        selectedPattern = pattern
        onPatternSelected?(pattern)
        navigateToSession = true
    }

    // MARK: - Decorative Background
    private var decorativeBackground: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Top-Left Green Circle
                Circle()
                    .fill(Color.brandColorAccentGreen.opacity(0.25))
                    .frame(width: width * 1.3, height: width * 0.9)
                    .position(x: width * 0.1, y: height * 0)
                
                // Bottom-Right Purple Wavy Line
                Path { path in
                    path.move(to: CGPoint(x: width * 0.18, y: height + 20))
                    path.addCurve(
                        to: CGPoint(x: width + 20, y: height * 0.81),
                        control1: CGPoint(x: width * 0.18, y: height * 0.87),
                        control2: CGPoint(x: width * 0.60, y: height * 0.94)
                    )
                }
                .stroke(
                    Color .brandColorSecondaryPink.opacity(0.2),
                    style: StrokeStyle(lineWidth: 7 , lineCap: .round, lineJoin: .round)
                )
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    NavigationStack {
        ChooseStrummingPatternView(
            bpm: 120,
            rhythm: "4/4",
            patterns: Array(StrumPatternLibrary.allPatterns().prefix(4)),
            chordSegments: nil
        )
    }
}

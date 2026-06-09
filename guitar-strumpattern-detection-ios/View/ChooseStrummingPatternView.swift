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
    var isFirstTime: Bool = false
    var onPatternSelected: ((StrummingPattern) -> Void)? = nil
    @State private var selectedPatternID: UUID? = nil
    @State private var selectedPattern: StrummingPattern? = nil
    @State private var navigateToSession = false

    var body: some View {
        ZStack {
            Color.bgPrimary
                .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    headerSection
                    patternList
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xxl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationDestination(isPresented: $navigateToSession) {
            let beats = selectedPattern?.beats ?? []
            PlayingSessionView(
                pattern: beats.isEmpty ? ChordGroup.samplePattern : beats,
                bpm: bpm,
                timeSignature: rhythm,
                isFirstTime: isFirstTime
            )
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Choose Your Preffered Strumming Pattern")
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

    private func metadataLabel(_ text: String) -> some View {
        Text(text)
            .font(AppFont.caption1Regular)
            .foregroundColor(.brandColorSecondaryPink)
    }

    // MARK: - Pattern List
    private var patternList: some View {
        StrummingPatternList(
            patterns: patterns,
            selectedPatternID: $selectedPatternID
        )
        .padding(.top, Spacing.sm)
        .onChange(of: selectedPatternID) { _, newID in
            guard let newID,
                  let pattern = patterns.first(where: { $0.id == newID })
            else { return }
            selectedPattern = pattern
            onPatternSelected?(pattern)
            navigateToSession = true
        }
        .padding(.top, Spacing.sm)
    }

    // MARK: - Decorative Background
    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(Color.accentGreen.opacity(0.35))
                .frame(width: 220, height: 220)
                .offset(x: -120, y: -280)

            decorativeWave
                .stroke(Color.accentPurple.opacity(0.8), lineWidth: 2)
                .frame(width: 180, height: 80)
                .offset(x: 140, y: 320)
        }
        .allowsHitTesting(false)
    }

    private var decorativeWave: some Shape {
        WaveShape()
    }
}

// MARK: - Wave Shape
private struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        path.move(to: CGPoint(x: 0, y: midY))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.5, y: midY - 20),
            control1: CGPoint(x: rect.width * 0.15, y: midY + 30),
            control2: CGPoint(x: rect.width * 0.35, y: midY - 40)
        )
        path.addCurve(
            to: CGPoint(x: rect.width, y: midY),
            control1: CGPoint(x: rect.width * 0.65, y: midY + 40),
            control2: CGPoint(x: rect.width * 0.85, y: midY - 30)
        )
        return path
    }
}

#Preview {
    NavigationStack {
        ChooseStrummingPatternView(
            bpm: 120,
            rhythm: "4/4",
            patterns: StrummingPattern.samples
        )
    }
}

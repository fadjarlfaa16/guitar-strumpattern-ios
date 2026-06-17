import SwiftUI

struct ChooseStrummingPatternView: View {
    let bpm: Int
    let rhythm: String
    let patterns: [StrummingPattern]
    var chordSegments: [StoredChordSegment]? = nil
    var audioURL: URL?

    var onPatternSelected: ((StrummingPattern) -> Void)? = nil

    @State private var selectedPatternID: UUID?
    @State private var selectedPattern: StrummingPattern?
    @State private var navigateToSession = false

    var body: some View {
        ZStack {
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

            ChoosePatternBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ChoosePatternHeader()

                    patternList
                        .padding(.top, Spacing.md)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.md)
            }
        }
        .navigationDestination(isPresented: $navigateToSession) {
            PatternNavigationDestination(
                selectedPattern: selectedPattern,
                chordSegments: chordSegments,
                bpm: bpm,
                rhythm: rhythm,
                audioURL: audioURL
            )
        }
    }

    private var patternList: some View {
        StrummingPatternList(
            bpm: bpm,
            rhythm: rhythm,
            patterns: patterns,
            selectedPatternID: $selectedPatternID,
            onPatternTap: selectPattern
        )
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

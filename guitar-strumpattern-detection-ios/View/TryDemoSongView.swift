import SwiftUI


struct TryDemoSongView: View {
    @State private var navigateToChoosePattern = false

    // MARK: - Demo Song Constants
    private static let demoBPM: Int = 60
    private static let demoTimeSignature: String = "4/4"

    // MARK: - Demo Chord Segments (parsed from bundled txt)
    /// Parses twinkle-twinkle-chords.txt (format: "startTime  endTime  label" per line)
    private var demoChordSegments: [StoredChordSegment] {
        guard let url = Bundle.main.url(forResource: "twinkle-twinkle-chords", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content
            .components(separatedBy: .newlines)
            .compactMap { line -> StoredChordSegment? in
                let parts = line.split(whereSeparator: \.isWhitespace)
                guard parts.count >= 3,
                      let start = Double(parts[0]),
                      let end = Double(parts[1]) else { return nil }
                let label = String(parts[2])
                return StoredChordSegment(startTime: start, endTime: end, label: label)
            }
    }

    // MARK: - Demo Audio URL (from bundle)
    private var demoAudioURL: URL? {
        Bundle.main.url(forResource: "twinkle-twinkle", withExtension: "mp3")
    }

    // MARK: - Recommended Patterns (based on real demo parameters)
    private var demoPatterns: [StrummingPattern] {
        let segments = demoChordSegments
        guard !segments.isEmpty else {
            // Fallback: show all patterns if txt failed to load
            return Array(StrumPatternLibrary.allPatterns().prefix(4))
        }
        return StrumPatternLibrary.recommendations(
            bpm: Self.demoBPM,
            timeSignature: Self.demoTimeSignature,
            chordSegments: segments
        )
    }

    var body: some View {
        ZStack {
            // Background
                Color.backgroundPrimaryBlack
                    .ignoresSafeArea()
                
                // Background Wavy Lines
                WelcomeBackgroundLines()
                    .ignoresSafeArea()
                
                // Main Content
                VStack (spacing: 0) {
                    // Header Section
                    
                    HeroHeader(title: "Let's Try a Demo Song", subtitle: "Get familiar with strumming detection before you start practicing.")
                    Spacer()
                    
                    
                    // Music Info Section
                    VStack(spacing: Spacing.lg) {
                        // Play Button + Metadata
                        // Headphone Icon
                        Image("beatsHeadphones")
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .foregroundColor(.brandColorAccentGreen)
                        MusicPlayer()
                        
                    }
                    .padding(.horizontal, Spacing .md)
                    
                    Spacer()
                    // Next Button
                    CustomButton(title: "Next") {
                        navigateToChoosePattern = true
                    }
                    .navigationDestination(isPresented: $navigateToChoosePattern) {
                        ChooseStrummingPatternView(
                            bpm: Self.demoBPM,
                            rhythm: Self.demoTimeSignature,
                            patterns: demoPatterns,
                            chordSegments: demoChordSegments,
                            audioURL: demoAudioURL
                        )
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.sm)
            }
            .preferredColorScheme(.dark)
    }
}

// MARK: - Decorative Background Lines
struct WelcomeBackgroundLines: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Top Green Line (Valley on left, peak on right)
                Path { path in
                    path.move(to: CGPoint(x: -0.5, y: height * 0.22))
                    path.addCurve(
                        to: CGPoint(x: width + 20, y: height * 0.12),
                        control1: CGPoint(x: width * 0.35, y: height * 0.40),
                        control2: CGPoint(x: width * 0.45, y: height * -0.1)
                    )
                }
                .stroke(
                    Color.brandColorAccentGreen.opacity(0.2),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                )
                
                // Bottom Purple Line (Valley near middle, peak near right-middle, exiting bottom)
                Path { path in
                    path.move(to: CGPoint(x: -1, y: height * 0.72))
                    path.addCurve(
                        to: CGPoint(x: width * 0.74, y: height + -80),
                        control1: CGPoint(x: width * 0.40, y: height * 0.80),
                        control2: CGPoint(x: width * 0.75, y: height * 0.72)
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
#Preview {
    TryDemoSongView()
}
    

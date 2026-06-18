import SwiftUI


struct TryDemoSongView: View {
    @State private var navigateToChoosePattern = false

    private let demoChords: [StoredChordSegment] = [
        StoredChordSegment(startTime: 0.0, endTime: 0.023, label: "N"),
        StoredChordSegment(startTime: 0.023, endTime: 4.760, label: "C"),
        StoredChordSegment(startTime: 4.760, endTime: 6.084, label: "F"),
        StoredChordSegment(startTime: 6.084, endTime: 7.338, label: "C"),
        StoredChordSegment(startTime: 7.338, endTime: 9.195, label: "F"),
        StoredChordSegment(startTime: 9.195, endTime: 10.403, label: "C"),
        StoredChordSegment(startTime: 10.403, endTime: 11.889, label: "G"),
        StoredChordSegment(startTime: 11.889, endTime: 13.003, label: "C")
    ]
    private let demoAudioURL = Bundle.main.url(forResource: "twinkle", withExtension: "mp3")

    var body: some View {
        ZStack {
            // Background
                Color.backgroundPrimaryBlack
                    .ignoresSafeArea()
                
                // Background Wavy Lines
            BackgroundLines(style:.welcome)
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
                        MusicPlayer(songTitle: "Twinkle Twinkle Little Star", bpm: 120, timeSignature: "4/4")
                        
                    }
                    .padding(.horizontal, Spacing .md)
                    
                    Spacer()
                    // Next Button
                    CustomButton(title: "Next") {
                        navigateToChoosePattern = true
                    }
                    .navigationDestination(isPresented: $navigateToChoosePattern) {
                        ChooseStrummingPatternView(
                            bpm: 120, rhythm: "4/4", patterns: Array(StrumPatternLibrary.allPatterns().prefix(4)),
                            chordSegments: demoChords,
                            audioURL: demoAudioURL,
                            songTitle: "Twinkle Twinkle Little Star"
                        )
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.sm)
            }
            .preferredColorScheme(.dark)
    }
}


#Preview {
    TryDemoSongView()
}
    

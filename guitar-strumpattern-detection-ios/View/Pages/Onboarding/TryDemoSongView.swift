import SwiftUI


struct TryDemoSongView: View {
    @State private var navigateToChoosePattern = false

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
                            bpm: 120, rhythm: "4/4", patterns: Array(StrumPatternLibrary.allPatterns().prefix(4))
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
    

import SwiftUI


struct TryDemoSongView: View {
    @State private var navigateToChoosePattern = false

    var body: some View {
        NavigationStack {
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
    

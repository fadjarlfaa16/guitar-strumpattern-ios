import SwiftUI


struct OnboardingWelcome: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundPrimaryBlack
                    .ignoresSafeArea()
                // Main Content
                VStack {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome")
                            .font(AppFont.largeTitleBold)
                            .foregroundStyle(.textPrimaryWhite)
                        
                        Text("Let's try our demo song first")
                            .font(AppFont.title3Regular)
                            .foregroundColor(.textPrimaryWhite)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    
                    // Music Info Section
                    VStack(spacing: 12) {
                        // Play Button + Metadata
                        // Headphone Icon
                        Image("beatsHeadphones")
                            .foregroundColor(.brandColorAccentGreen)
                        MusicPlayer()
                        
                    }
                    
                    Spacer()
                    // Next Button
                    NavigationLink(destination: PrepareYourGuitarView()) {
                        CustomButton(title: "Next")
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
#Preview {
    OnboardingWelcome()
}
    

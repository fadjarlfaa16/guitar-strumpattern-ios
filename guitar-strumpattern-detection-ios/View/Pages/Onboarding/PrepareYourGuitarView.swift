//
//  PrepareYourGuitarView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Eka Feby Ronauli Lubis on 08/06/26.
//

import SwiftUI


struct PrepareYourGuitarView: View {
    @State private var navigateToWatchCheck = false
    @AppStorage("navRoot") private var navRoot: NavRoot = .songList

    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()
            
            // Background Wavy Lines
            BackgroundLines(style:.prepareGuitar)
                .ignoresSafeArea()
            
            // Main Content
            VStack {
                // Header Section
                HeroHeader(
                    title: "Prepare Your Guitar and Apple Watch",
                    subtitle: "You'll need a guitar and an Apple Watch to practice your strumming"
                )
                
                Spacer()
                
                Image("guitars.fill")
                    .foregroundColor(.brandColorAccentGreen)
                
                Spacer()
                
                // Next Button
                VStack(spacing: Spacing.sm) {
                    CustomButton(title: "Next") {
                        navigateToWatchCheck = true
                    }
                    .navigationDestination(isPresented: $navigateToWatchCheck) {
                        AppleWatchCheckView()
                    }
                    SecondaryTextButton(title: "Skip for Now") {
                        navRoot = .songList
                    }
                }
                }
            .padding(.horizontal, 24)
            }
        }
    }


#Preview {
    PrepareYourGuitarView()
}

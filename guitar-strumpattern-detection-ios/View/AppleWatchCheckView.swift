//
//  AppleWatchCheckView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//


import SwiftUI

struct AppleWatchCheckView: View {
    @State private var navigateToCalibrateWatch = false
    @AppStorage("appState") private var appState: AppState = .onboarding
    let isWatchConnected: Bool

    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()
            
            // Background Wavy Lines
            PrepareGuitarBackgroundLines()
                .ignoresSafeArea()
            
            // Main Content
            VStack {
                // Header Section
                HeroHeader(title: isWatchConnected ? "Ready with your Apple Watch?" : "Apple Watch Required", subtitle: isWatchConnected ? "Wear it on your strumming hand so we can detect your strumming movements." : "We use your Apple Watch to detect your strumming movements.")
                
                Spacer()
                
                ZStack {
                    Image(systemName: "applewatch")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.brandColorAccentGreen)
                        .frame(width: 168)
                    Image(systemName: isWatchConnected ? "checkmark.circle.fill" : "x.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isWatchConnected ? .green : .red)
                        .frame(width: 42)
                        .offset(x: 60, y: 105)
                }
                
                Spacer()
                
                // Next Button
                if isWatchConnected {
                VStack(spacing: 12) {
                        CustomButton(title: "Next") {
                            navigateToCalibrateWatch = true
                        }
                        Button(action: {
                            appState = .songList
                        }) {
                            Text("Skip for Now")
                                .font(AppFont.bodyRegular)
                                .foregroundColor(.brandColorPrimaryPurple)
                        }
                    }
                    .navigationDestination(isPresented: $navigateToCalibrateWatch) {
                        CalibrateWatchView()
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    AppleWatchCheckView(isWatchConnected: true)
}

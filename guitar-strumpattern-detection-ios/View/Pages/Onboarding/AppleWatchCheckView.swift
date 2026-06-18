//
//  AppleWatchCheckView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//


import SwiftUI

struct AppleWatchCheckView: View {
    @State private var navigateToCalibrateWatch = false
    @AppStorage("appState") private var appState: NavRoot = .onboarding
    @ObservedObject private var watchSession = WatchSessionManager.shared

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
                HeroHeader(title: watchSession.isConnected ? "Ready with your Apple Watch?" : "Apple Watch Required", subtitle: watchSession.isConnected ? "Wear it on your strumming hand so we can detect your strumming movements." : "We use your Apple Watch to detect your strumming movements.")
                
                Spacer()
                
                ZStack {
                    Image(watchSession.isConnected ? .applewatchBadgeCheckmark : .applewatchBadgeExclamationmark)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.brandColorAccentGreen)
                        .frame(width: 168)
                }
                
                Spacer()
                
                // Next Button
                if watchSession.isConnected {
                VStack(spacing: 12) {
                    CustomButton(title: "Next") {
                            navigateToCalibrateWatch = true
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
    AppleWatchCheckView()
}

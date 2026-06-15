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
            PrepareGuitarBackgroundLines()
                .ignoresSafeArea()
            
            // Main Content
            VStack {
                // Header Section
                PrepareHeader()
                
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
                        AppleWatchCheckView(
                            isWatchConnected: true
                        )
                    }
                    Button(action: {
                        navRoot = .songList
                    }) {
                        Text("Skip for Now")
                            .font(AppFont.bodyRegular)
                            .foregroundColor(.brandColorPrimaryPurple)
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

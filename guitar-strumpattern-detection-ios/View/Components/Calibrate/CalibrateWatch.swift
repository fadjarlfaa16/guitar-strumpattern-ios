//
//  CalibrateWatch.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//
import SwiftUI


struct CalibrateWatchView: View {
    @State private var navigateToWatchCheck = false
    @State private var strumDirection: StrumBeat = .up

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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let’s calibrate your watch first")
                        .font(AppFont.largeTitleBold)
                        .foregroundStyle(.textPrimaryWhite)
                    
                    Text("Strum \(strumDirection == .up ? "up" : "down") 5 times on your guitar")
                        .font(AppFont.title3Regular)
                        .foregroundColor(.textPrimaryWhite)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(spacing: Spacing.xl) {
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.brandColorAccentGreen)
                        .frame(width: 168)
                        .fontWeight(.bold)
                        .symbolRenderingMode(.hierarchical)
                
                    HStack {
                        Spacer()
                        ArrowIcon(foregroundStyle: .green, direction: strumDirection)
                        Spacer()
                        ArrowIcon(direction: strumDirection)
                        Spacer()
                        ArrowIcon(direction: strumDirection)
                        Spacer()
                        ArrowIcon(direction: strumDirection)
                        Spacer()
                        ArrowIcon(direction: strumDirection)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Next Button
                VStack(spacing: 12) {
                    // TODO: Buat kalau belum selesai disabled
                    CustomButton(title: "Next", isDisabled: false) {
                        navigateToWatchCheck = true
                    }
                }
                .navigationDestination(isPresented: $navigateToWatchCheck) {
                    CalibrateCompleteView()
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    CalibrateWatchView()
}

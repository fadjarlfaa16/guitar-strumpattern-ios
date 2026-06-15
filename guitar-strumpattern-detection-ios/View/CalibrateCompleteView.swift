//
//  CalibrateCompleteView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//
import SwiftUI


struct CalibrateCompleteView: View {
    @State private var navigateToTryWatchView = false
    @State private var strumDirection: StrumBeat = .up

    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()
            
            // Main Content
            VStack {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("You're all set")
                        .font(AppFont.largeTitleBold)
                        .foregroundStyle(.textPrimaryWhite)
                    
                    Text("Your watch is ready to go.")
                        .font(AppFont.title3Regular)
                        .foregroundColor(.textPrimaryWhite)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.brandColorAccentGreen)
                    .frame(width: 200)
                    .fontWeight(.bold)
                    .symbolRenderingMode(.hierarchical)
                
                
                Spacer()
                
                // Next Button
                VStack(spacing: 12) {
                    // TODO: Buat kalau belum selesai disabled
                    CustomButton(title: "Next") {
                        navigateToTryWatchView = true
                    }
                }
                .navigationDestination(isPresented: $navigateToTryWatchView) {
                    TryDemoSongView()
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    CalibrateCompleteView()
}



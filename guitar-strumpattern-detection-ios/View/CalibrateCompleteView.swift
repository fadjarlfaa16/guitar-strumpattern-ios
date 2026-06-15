//
//  CalibrateCompleteView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//
import SwiftUI


struct CalibrateCompleteView: View {
    @State private var navigateToTryWatchView = false
    var onReset: () -> Void = {}

    var body: some View {
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

            VStack(spacing: 12) {
                CustomButton(title: "Next") {
                    navigateToTryWatchView = true
                }

                Button(action: onReset) {
                    Text("Reset")
                        .font(AppFont.bodyRegular)
                        .foregroundColor(.brandColorPrimaryPurple)
                }
            }
            .navigationDestination(isPresented: $navigateToTryWatchView) {
                TryDemoSongView()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimaryBlack.ignoresSafeArea()
        CalibrateCompleteView()
            .padding(.horizontal, 24)
    }
}



//
//  CalibrateCompleteView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//
import SwiftUI


struct CalibrateCompleteView: View {
    @Environment(\.dismiss) private var dismiss
    let isRecalibrating: Bool
    
    @State private var navigateToTryWatchView = false
    var onReset: () -> Void = {}
    
    init(isRecalibrating: Bool = false, onReset: @escaping () -> Void = {}) {
        self.isRecalibrating = isRecalibrating
        self.onReset = onReset
    }

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
                if isRecalibrating {
                    CustomButton(title: "Done") {
                        dismiss()
                    }
                } else {
                    CustomButton(title: "Next") {
                        navigateToTryWatchView = true
                    }
                }

                SecondaryTextButton(title: "Reset", action: onReset)
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



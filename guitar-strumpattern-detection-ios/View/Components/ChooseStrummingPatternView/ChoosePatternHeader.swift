//
//  ChoosePatternHeader.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


import SwiftUI

struct ChoosePatternHeader: View {
    @State private var navigateToRecalibrate = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Choose Your Preferred Strumming Pattern")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text("These patterns are choosed based on the song's BPM and rhythm")
                .font(AppFont.bodyRegular)
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                WatchStatusView()
                Spacer()
                Button("Recalibrate") {
                    navigateToRecalibrate.toggle() 
                }
                .navigationDestination(isPresented: $navigateToRecalibrate) {
                    CalibrateWatchView(
                        isRecalibrating: true
                    )
                }
                .foregroundStyle(.textPrimaryWhite)
            }
        }
    }
}
#Preview {
    ChoosePatternHeader()
}

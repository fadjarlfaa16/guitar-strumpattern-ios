//
//  WatchStatusView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//

import SwiftUI

struct WatchStatusView: View {
    var isConnected: Bool = false
    var body: some View {
        HStack(spacing: Spacing.lg) {
            HStack {
                Image(systemName: "applewatch")
                    .foregroundStyle(.white)
                VStack(alignment: .leading) {
                    Text("Apple Watch")
                        .foregroundStyle(.textPrimaryWhite)
                    Text(isConnected ? "Connected" : "Not Connected")
                        .foregroundStyle(isConnected ? .green : .red)
                }
            }
            if isConnected {
                CustomButton(title: "Recalibrate")
            } else {
                Spacer()
            }
        }
        .padding(16)
        .background(.brandColorAccentGreen.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        WatchStatusView()
    }
}

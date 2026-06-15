//
//  WatchStatusView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//

import SwiftUI

struct WatchStatusView: View {
    @ObservedObject private var watchSession = WatchSessionManager.shared
    var onRecalibrate: () -> Void = {}

    @State private var showWatchInstructions = false

    var body: some View {
        HStack(spacing: Spacing.lg) {
            HStack {
                Image(systemName: "applewatch")
                    .foregroundStyle(.white)
                VStack(alignment: .leading) {
                    Text("Apple Watch")
                        .foregroundStyle(.textPrimaryWhite)
                    Text(watchSession.statusMessage)
                        .foregroundStyle(watchSession.isConnected ? .green : .red)
                }
            }

            Spacer()

            if watchSession.isConnected {
                CustomButton(title: "Recalibrate", action: onRecalibrate)
                    .frame(maxWidth: 140)
            } else {
                CustomButton(title: "Open Watch App") {
                    watchSession.requestWatchAppLaunch()
                    showWatchInstructions = true
                }
                .frame(maxWidth: 160)
            }
        }
        .padding(16)
        .background(.brandColorAccentGreen.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
        .onAppear {
            watchSession.activate()
        }
        .alert("Open on Apple Watch", isPresented: $showWatchInstructions) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(watchSession.openWatchInstructionsMessage)
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        WatchStatusView()
            .padding()
    }
}

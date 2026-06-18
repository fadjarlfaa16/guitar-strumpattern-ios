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
                Image(watchSession.isConnected ? .applewatchBadgeCheckmark : .applewatchBadgeExclamationmark)
                    .foregroundStyle(.white)
                Text(watchSession.statusMessage)
                    .foregroundStyle(watchSession.isConnected ? .green : .red)
                    .font(AppFont.caption1Bold)
                
            }

//            if watchSession.isConnected {
//                CustomButton(title: "Recalibrate", action: onRecalibrate)
//                    .frame(maxWidth: 140)
//            } else {
//                CustomButton(title: "Open Watch App") {
//                    watchSession.requestWatchAppLaunch()
//                    showWatchInstructions = true
//                }
//                .frame(maxWidth: 160)
//            }
        }
        .padding(Spacing.sm)
        .background(watchSession.isConnected ? Color.greenSurface : Color.redSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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

//
//  WatchStatusView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//

import SwiftUI

struct WatchStatusView: View {
    @ObservedObject private var watchSession = WatchSessionManager.shared

    @State private var showWatchInstructions = false
    var onWakeAndSync: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.lg) {
            HStack {
                Image(watchSession.isWatchAppActive ? .applewatchBadgeCheckmark : .applewatchBadgeExclamationmark)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .foregroundStyle(.white)
                Text(watchSession.statusMessage)
                    .foregroundStyle(watchSession.isWatchAppActive ? .green : .red)
                    .font(AppFont.caption1Bold)
                if !watchSession.isWatchAppActive {
                    Button {
                        WatchSessionManager.shared.requestWatchAppLaunch()
                        onWakeAndSync?()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)                    
                }
                
            }
        }
        .padding(Spacing.sm)
        .background(watchSession.isWatchAppActive ? Color.greenSurface : Color.redSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            if !watchSession.isWatchAppActive {
                showWatchInstructions = true
            }
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

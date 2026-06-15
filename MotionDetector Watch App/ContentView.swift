//
//  ContentView.swift
//  MotionDetector Watch App
//
//  Created by Arif Fathurrahman on 12/06/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var detector = StrumDetector()
    
    var body: some View {
        Group {
            switch detector.currentWatchState {
            case .disconnected:
                DisconnectedView()
            case .calibrating:
                CalibratingView(detector: detector)
            case .waitingForSong:
                WaitingForSongView()
            case .playing:
                PlayingSessionWatchView(detector: detector)
            }
        }
        .onAppear { detector.startDetecting() }
        .onDisappear { detector.stopDetecting() }
    }
}

// MARK: - Disconnected View
struct DisconnectedView: View {
    var body: some View {
        VStack {
            Image(systemName: "iphone.slash")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding(.bottom, 8)
            Text("Open the app on your phone to continue")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// MARK: - Calibrating View
struct CalibratingView: View {
    @ObservedObject var detector: StrumDetector

    private var isDown: Bool {
        detector.calibrationState == .calibratingDown
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: isDown ? "arrow.down" : "arrow.up")
                .font(.largeTitle)
                .bold()
                .foregroundColor(isDown ? .blue : .green)
            
            Text(detector.calibrationStatusText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            
            ProgressView(value: Double(detector.recordedSamplesCount), total: Double(detector.targetSamples))
                .tint(isDown ? .blue : .green)
            
            Text("\(detector.recordedSamplesCount) / \(detector.targetSamples)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// MARK: - Waiting For Song View
struct WaitingForSongView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Waiting for song")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Playing Session Watch View
struct PlayingSessionWatchView: View {
    @ObservedObject var detector: StrumDetector
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Marquee Title (Basic implementation using ScrollView)
            ScrollView(.horizontal, showsIndicators: false) {
                Text(detector.songTitle.isEmpty ? "Unknown Song" : detector.songTitle)
                    .font(.headline)
                    .bold()
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            // Progress Bar
            let safeCur = min(max(detector.currentTime, 0), max(detector.maxTime, 0.1))
            let safeMax = max(detector.maxTime, 0.1)
            ProgressView(value: safeCur.isNaN ? 0 : safeCur, total: safeMax.isNaN ? 1 : safeMax)
                .tint(.green)
            
            // Time Track
            Text("\(formatTime(detector.currentTime)) / \(formatTime(detector.maxTime))")
                .font(.footnote.monospacedDigit())
                .foregroundColor(.gray)
            
            // Pause / Play Button
            Button(action: {
                detector.togglePauseFromWatch()
            }) {
                Image(systemName: detector.isPlayingPaused ? "play.fill" : "pause.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .tint(detector.isPlayingPaused ? .green : .red)
        }
        .padding()
    }
}

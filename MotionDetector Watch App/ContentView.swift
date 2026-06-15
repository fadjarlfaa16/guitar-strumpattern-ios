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
        VStack(spacing: 10) {
            Text("Sensor Aktif 🎸")
                .font(.headline)
                .foregroundColor(.green)
            
            Divider()
            
            VStack {
                Text("Strum:")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text(detector.lastStrum)
                    .font(.title)
                    .bold()
                    .foregroundColor(
                        detector.lastStrum == "Down" ? .blue :
                        (detector.lastStrum == "Up" ? .red :
                        (detector.lastStrum == "Diam" ? .gray : .primary))
                    )
            }
            
            if detector.calibrationState != .idle {
                Text("Sedang Kalibrasi...")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .padding(.top, 5)
            }
        }
        .padding()
        .onAppear { detector.startDetecting() }
        .onDisappear { detector.stopDetecting() }
    }
}

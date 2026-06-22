//
//  AnalysisResultView.swift
//

import SwiftUI

struct AnalysisResultView: View {
    let result: ChordAnalysisResult
    let onConfirm: () -> Void
    let songTitle: String
    
    var body: some View {
        VStack(spacing: 36) {

            // Header
            Text("Analyzing Audio")
                .font(AppFont.title3Bold)
                .foregroundStyle(.white)

            // Result Card
            VStack(spacing: 20) {
                Text("Unique Chord Detected: ")
                    .font(AppFont.bodyRegular)
                    .foregroundStyle(.brandColorAccentGreen)

                let uniqueChords = Set(result.chordSegments.map(\.label))
                Text("\(uniqueChords.count) Chords")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.brandColorAccentGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        Color(
                            red: 0.25,
                            green: 0.23,
                            blue: 0.18
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                .brandColorAccentGreen.opacity(0.7),
                                lineWidth: 1
                            )
                    )
            )

            // Continue Button
            CustomButton(
                title: "Continue",
                action: onConfirm
            )

            // Song Info
            VStack(alignment: .leading, spacing: 4) {
                Text(songTitle.uppercased() )
               
            }
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(hex: "09081A"))
        )
    }
}

#Preview {
    AnalysisResultView(
        result: ChordAnalysisResult(
            bpm: 120,
            timeSignature: "4/4",
            chordSegments: [
                StoredChordSegment(startTime: 0, endTime: 2, label: "C"),
                StoredChordSegment(startTime: 2, endTime: 4, label: "G"),
                StoredChordSegment(startTime: 4, endTime: 6, label: "Am"),
                StoredChordSegment(startTime: 6, endTime: 8, label: "F"),
                StoredChordSegment(startTime: 8, endTime: 10, label: "C"),
                StoredChordSegment(startTime: 10, endTime: 12, label: "G"),
            ]
        ),
        onConfirm: {},
        songTitle: "Lirik Payung Teduh - Untuk Perempuan Yang Sedang Dalam Pelukan"
    )
    .padding()
    .background(.black)
}

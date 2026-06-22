//
//  AnalyzeMusicModal.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 09/06/26.
//

import SwiftUI

struct AnalyzeMusicModal: View {

    // MARK: - Parameters

    let song: Song
    var onAnalysisComplete: (ChordAnalysisResult) -> Void
    var onDismiss: () -> Void

    // MARK: - State

    @State var isAnalyzing = false
    @State var analysisResult: ChordAnalysisResult? = nil
    @State var analysisError: String? = nil
    @State var progress: Double = 0
    @State var analysisStage: String = "Analyzing Music..."

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                if let result = analysisResult {
                    AnalysisResultView(
                        result: result,
                        onConfirm: {
                            onAnalysisComplete(result)
                            onDismiss()
                        },
                        songTitle: song.title
                    )
                } else if let error = analysisError {
                    AnalysisErrorView(error: error) {
                        analysisError = nil
                        Task { await runAnalysis() }
                    }
                } else {
                    AnalysisLoadingView(progress: progress, stage: analysisStage)
                }

            }
            .padding(24)
            .padding(.horizontal, 20)

        }
        .task(id: song.id) {
            await runAnalysis()
        }
    }
}

// MARK: - Preview

#Preview("Analysis Complete") {
    AnalyzeMusicModal(
        song: Song(
            title: "Untuk Perempuan Yang Sedang Dalam Pelukan",
            artist: "Payung Teduh",
            sandboxFileName: "payung_teduh.mp3",
            duration: 245
        ),
        onAnalysisComplete: { _ in },
        onDismiss: {}
    )
}

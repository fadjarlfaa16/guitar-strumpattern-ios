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

    @State private var isAnalyzing = false
    @State private var analysisResult: ChordAnalysisResult? = nil
    @State private var analysisError: String? = nil
    @State private var progress: Double = 0
    @State private var animatingIndex: Int = 0
    @State private var analysisStage: String = "Analyzing BPM & Time Signature..."

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                Text("Analyzing Audio")
                    .font(AppFont.title3Bold)
                    .foregroundStyle(.textPrimaryWhite)

                if let result = analysisResult {
                    VStack(spacing: 28) {

                        // Header
                        VStack(spacing: 12) {
                            Text("Analysis Complete")
                                .font(.system(size: 32, weight: .bold))

                            Text("Analysis finished successfully")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            Text("100%")
                                .font(.title2.bold())
                                .foregroundStyle(.brandColorAccentGreen)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(.brandColorAccentGreen)
                        }

                        // Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 12)

                                Capsule()
                                    .fill(.brandColorAccentGreen)
                                    .frame(width: geo.size.width, height: 12)
                            }
                        }
                        .frame(height: 12)

                        // Confirm Button
                        Button {
                            onAnalysisComplete(result)
                            onDismiss()
                        } label: {
                            Text("Confirm & Continue")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.35, green: 0.08, blue: 0.15),
                                                    Color(red: 0.20, green: 0.05, blue: 0.10)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }

                        // Result Summary
                        VStack(alignment: .leading, spacing: 14) {

                            resultRow(
                                title: "BPM",
                                value: "\(result.bpm)"
                            )

                            resultRow(
                                title: "Time Signature",
                                value: result.timeSignature
                            )

                            resultRow(
                                title: "Chords Detected",
                                value: "\(result.chordSegments.count)"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(hex: "09081A"))
                    )
                    .padding(.horizontal)
                
                } else if let error = analysisError {
                    // MARK: Error State
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.brandColorSecondaryPink)

                        Text("Analysis Failed")
                            .font(AppFont.title3Bold)
                            .foregroundStyle(.textPrimaryWhite)

                        Text(error)
                            .font(AppFont.bodyRegular)
                            .foregroundStyle(.textPrimaryWhite.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Button(action: {
                            analysisError = nil
                            Task { await runAnalysis() }
                        }) {
                            Text("Retry")
                                .font(AppFont.bodyBold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.brandColorPrimaryPurple)
                                )
                        }
                    }
                } else {
                    // MARK: Loading State
                    VStack(spacing: 24) {
                        // Progress Indicator
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .brandColorAccentGreen))
                            .scaleEffect(y: 2, anchor: .center)

                        VStack(spacing: 8) {
                            Text(analysisStage)
                                .font(AppFont.bodyRegular)
                                .foregroundStyle(.textPrimaryWhite)

                            Text(String(format: "%.0f%%", progress * 100))
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.brandColorAccentGreen)
                        }

                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.brandColorAccentGreen)
                                    .frame(width: 4, height: 24)
                                    .opacity(animatingIndex == index ? 1 : 0.3)
                            }
                        }
                        .task {
                            while !Task.isCancelled {
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                withAnimation {
                                    animatingIndex = (animatingIndex + 1) % 3
                                }
                            }
                        }
                    }
                }

                // MARK: Song Info
                VStack(spacing: 8) {
                    Text(song.title)
                        .font(AppFont.bodyBold)
                        .foregroundStyle(.textPrimaryWhite)

                    if let artist = song.artist {
                        Text(artist)
                            .font(AppFont.bodyRegular)
                            .foregroundStyle(.textPrimaryWhite.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hue: 0.75, saturation: 0.3, brightness: 0.15))
            )
            .padding(.horizontal, 20)
        }
        .task(id: song.id) {
            await runAnalysis()
        }
    }

    // MARK: - Subviews

    private func resultCard(label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.brandColorAccentGreen.opacity(0.8))

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(.brandColorAccentGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brandColorAccentGreen.opacity(0.1))
                .strokeBorder(Color.brandColorAccentGreen.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Analysis

    private func runAnalysis() async {
        isAnalyzing = true
        analysisError = nil
        withAnimation(.easeOut(duration: 0.3)) { progress = 0 }
        analysisStage = "Validating audio file..."

        do {
            let audioURL = SongLibraryStore.audioDirectory.appendingPathComponent(song.sandboxFileName)

            guard FileManager.default.fileExists(atPath: audioURL.path) else {
                throw NSError(
                    domain: "AnalyzeMusicModal", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Audio file tidak ditemukan. Coba upload ulang."]
                )
            }

            guard FileManager.default.isReadableFile(atPath: audioURL.path) else {
                throw NSError(
                    domain: "AnalyzeMusicModal", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Tidak bisa membaca file audio. Cek permission."]
                )
            }

            withAnimation(.easeOut(duration: 0.3)) { progress = 0.04 }
            analysisStage = "Starting analysis pipeline..."
            var progressContinuation: AsyncStream<(Double, String)>.Continuation?
            let progressStream = AsyncStream<(Double, String)> { cont in
                progressContinuation = cont
            }
            let continuation = progressContinuation!

            // Jalankan analisis di background thread
            let analysisTask = Task.detached(priority: .userInitiated) {
                let r = Result {
                    try ChordAnalyzer.shared.analyze(audioURL: audioURL) { prog, stage in
                        continuation.yield((prog, stage))
                    }
                }
                continuation.finish()
                return r
            }

            // Timeout: cancel task jika terlalu lama
            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 600 * 1_000_000_000)
                analysisTask.cancel()
                continuation.finish()
            }

            // Konsumsi progress update di main actor dengan animasi smooth
            for await (prog, stage) in progressStream {
                withAnimation(.easeInOut(duration: 0.5)) { progress = prog }
                analysisStage = stage
            }

            timeoutTask.cancel()

            // Ambil hasil dari background task
            let result = try await analysisTask.value.get()

            withAnimation(.easeInOut(duration: 0.4)) { progress = 0.97 }
            analysisStage = "Processing results..."
            try await Task.sleep(nanoseconds: 200_000_000)

            withAnimation(.easeOut(duration: 0.5)) { progress = 1.0 }
            analysisStage = "Complete!"
            try await Task.sleep(nanoseconds: 500_000_000)

            analysisResult = result
            isAnalyzing = false

        } catch is CancellationError {
            // .task modifier cancel saat view disappear — tidak perlu error message
            isAnalyzing = false
        } catch {
            analysisError = getErrorMessage(error)
            isAnalyzing = false
        }
    }

    private func resultRow(
        title: String,
        value: String
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        let errorDesc = error.localizedDescription
        if errorDesc.contains("timed out") || errorDesc.contains("timeout") {
            return "Analisis timeout. Inference full-song terlalu lama untuk file ini. Coba ulang atau pakai file yang lebih pendek untuk validasi."
        }
        if errorDesc.contains("not found") || errorDesc.contains("tidak ditemukan") {
            return "Audio file tidak ditemukan. Coba upload ulang."
        }
        if errorDesc.contains("permission") || errorDesc.contains("denied") {
            return "Permission denied. Cek storage access."
        }
        if errorDesc.contains("decode") || errorDesc.contains("format") {
            return "Format audio tidak support. Gunakan MP3 atau WAV."
        }
        if errorDesc.contains("Model not found") || errorDesc.contains("filterbanks") {
            return "Model analisis tidak ditemukan. Pastikan resource ML ada di bundle."
        }
        return errorDesc.isEmpty ? "Analisis gagal. Coba lagi." : errorDesc
    }
}

// MARK: - Preview

#Preview {
    AnalyzeMusicModal(
        song: Song(
            title: "Sample Song",
            artist: "Sample Artist",
            sandboxFileName: "test.mp3"
        ),
        onAnalysisComplete: { result in
            print("BPM: \(result.bpm), Time Signature: \(result.timeSignature), Chords: \(result.chordSegments.count)")
        },
        onDismiss: {}
    )
}

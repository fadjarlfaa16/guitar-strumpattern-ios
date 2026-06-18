//
//  dengan.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 19/06/26.
//
import SwiftUI

extension AnalyzeMusicModal {

    // MARK: - Analysis

    func runAnalysis() async {
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

    func getErrorMessage(_ error: Error) -> String {
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

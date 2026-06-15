//
//  BPM+TimeSignatureAnalyzer.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 09/06/26.
//

import Foundation
import Accelerate

struct AudioAnalysisResult {
    let bpm: Int
    let timeSignature: String
}

final class BPMTimeSignatureAnalyzer {
    static let shared = BPMTimeSignatureAnalyzer()
    private init() {}

    // Audio parameters (must match AudioLoader target sample rate)
    private let sampleRate: Float = 22050
    private let fftSize: Int = 2048
    private let hopLength: Int = 256

    // MARK: - Public Entry Point

    func analyze(audioURL: URL) async throws -> AudioAnalysisResult {
        let samples = try await AudioLoader.load(url: audioURL)
        return analyze(samples: samples)
    }

    func analyze(samples: [Float]) -> AudioAnalysisResult {
        let odf = onsetDetectionFunction(samples: samples)
        let bpm = estimateBPM(odf: odf)
        let timeSig = estimateTimeSignature(odf: odf, bpm: bpm)
        return AudioAnalysisResult(bpm: bpm, timeSignature: timeSig)
    }

    // MARK: - Onset Detection Function (ODF)
    private func onsetDetectionFunction(samples: [Float]) -> [Float] {
        let frameRate = sampleRate / Float(hopLength)

        var frames: [[Float]] = []
        var pos = 0
        while pos + fftSize <= samples.count {
            let frame = Array(samples[pos..<(pos + fftSize)])
            frames.append(powerSpectrum(applyHannWindow(frame)))
            pos += hopLength
        }
        guard frames.count > 2 else { return [] }

        let maxFiltered = frames.map { maxFilterSpectrum($0, width: 3) }

        var odf = [Float](repeating: 0, count: maxFiltered.count)
        for i in 1..<maxFiltered.count {
            var flux: Float = 0
            let curr = maxFiltered[i]
            let prev = maxFiltered[i - 1]
            for j in 0..<min(curr.count, prev.count) {
                let d = curr[j] - prev[j]
                if d > 0 { flux += d }
            }
            odf[i] = flux
        }

        let detrWindow = Int(2.0 * frameRate)
        odf = subtractLocalMean(odf, windowSize: detrWindow)
        odf = odf.map { max(0, $0) }

        if let mx = odf.max(), mx > 0 {
            let inv = 1.0 / mx
            odf = odf.map { $0 * inv }
        }

        return odf
    }

    // MARK: - BPM Estimation via Autocorrelation Tempogram
    private func estimateBPM(odf: [Float]) -> Int {
        let frameRate = sampleRate / Float(hopLength)

        // Search range: 60–160 BPM.
        //
        // Why cap at 160?
        // A guitar song at 84 BPM strummed on every 8th note generates onsets at
        // 168 BPM. Without the cap, the ACF peak at 168 (more frequent events) beats
        // the one at 84, giving a 2× error. 168 BPM is outside this window → problem gone.
        // Virtually no pop/folk/rock guitar song has a BEAT (quarter note) above 160 BPM.
        //
        // Why floor at 60?
        // Below 60 BPM the ODF is too sparse for a reliable ACF estimate.
        let bpmLo: Float = 60
        let bpmHi: Float = 160
        let lagMin = max(1, Int((60.0 / bpmHi) * frameRate))
        let lagMax = Int((60.0 / bpmLo) * frameRate)
        guard lagMax < odf.count else { return 120 }

        let N = odf.count
        let lagCount = lagMax - lagMin + 1

        // Energy-normalised autocorrelation
        var acf = [Float](repeating: 0, count: lagCount)
        for k in lagMin...lagMax {
            let n = N - k
            guard n > 0 else { continue }
            var num: Float = 0, e1: Float = 0, e2: Float = 0
            for i in 0..<n {
                num += odf[i] * odf[i + k]
                e1  += odf[i] * odf[i]
                e2  += odf[i + k] * odf[i + k]
            }
            let denom = sqrt(e1 * e2)
            acf[k - lagMin] = denom > 0 ? num / denom : 0
        }

        let sigma: Float = 0.6
        let centre: Float = 105.0
        var weighted = [Float](repeating: 0, count: lagCount)
        for i in 0..<lagCount {
            let bpmVal = 60.0 * frameRate / Float(i + lagMin)
            let logR = log(bpmVal / centre)
            let w = exp(-0.5 * logR * logR / (sigma * sigma))
            weighted[i] = acf[i] * w
        }

        guard let bestIdx = weighted.indices.max(by: { weighted[$0] < weighted[$1] }) else {
            return 120
        }

        var trueLag = Float(bestIdx + lagMin)
        if bestIdx > 0 && bestIdx < lagCount - 1 {
            let y0 = weighted[bestIdx - 1]
            let y1 = weighted[bestIdx]
            let y2 = weighted[bestIdx + 1]
            let denom2 = y0 - 2 * y1 + y2
            if denom2 < 0 {
                let offset = 0.5 * (y0 - y2) / denom2
                trueLag += max(-0.5, min(0.5, offset))
            }
        }

        let bpm = Int(round(60.0 * frameRate / trueLag))
        return max(60, min(160, bpm))
    }

    // MARK: - Time Signature Estimation
    private func estimateTimeSignature(odf: [Float], bpm: Int) -> String {
        let frameRate = sampleRate / Float(hopLength)
        let beatPeriod = (60.0 / Float(bpm)) * frameRate
        guard beatPeriod > 1 else { return "4/4" }

        // Find phase that maximises beat-grid energy
        let nPhase = max(1, Int(beatPeriod))
        var bestPhase: Float = 0, bestPhaseScore: Float = -1
        for p in 0..<nPhase {
            var score: Float = 0
            var pos = Float(p)
            while pos < Float(odf.count) {
                let lo = Int(pos), hi = min(lo + 1, odf.count - 1)
                let f = pos - Float(lo)
                score += odf[lo] * (1 - f) + odf[hi] * f
                pos += beatPeriod
            }
            if score > bestPhaseScore { bestPhaseScore = score; bestPhase = Float(p) }
        }


        let maxBeats = max(18, Int(20.0 * Float(bpm) / 60.0))
        var beatE: [Float] = []
        var pos = bestPhase
        while pos < Float(odf.count) && beatE.count < maxBeats {
            let lo = Int(pos), hi = min(lo + 1, odf.count - 1)
            let f = pos - Float(lo)
            beatE.append(odf[lo] * (1 - f) + odf[hi] * f)
            pos += beatPeriod
        }
        guard beatE.count >= 18 else { return "4/4" }


        func fold(_ period: Int) -> Float {
            var profile = [Float](repeating: 0, count: period)
            for i in 0..<beatE.count { profile[i % period] += beatE[i] }
            let mean = profile.reduce(0, +) / Float(period)
            guard mean > 0 else { return 1 }
            return (profile.max() ?? 0) / mean
        }

        let s3 = fold(3)
        let s4 = fold(4)
        return s3 > s4 * 1.10 ? "3/4" : "4/4"
    }

    // MARK: - DSP Helpers
    private func applyHannWindow(_ signal: [Float]) -> [Float] {
        let N = signal.count
        var window = [Float](repeating: 0, count: N)
        var result = [Float](repeating: 0, count: N)
        vDSP_hann_window(&window, vDSP_Length(N), Int32(vDSP_HANN_NORM))
        vDSP_vmul(signal, 1, window, 1, &result, 1, vDSP_Length(N))
        return result
    }

    // Power spectrum via vDSP real FFT (mono float32 input)
    private func powerSpectrum(_ signal: [Float]) -> [Float] {
        let n = signal.count
        let halfN = n / 2
        let log2n = vDSP_Length(log2(Float(n)))
        guard let setup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return [Float](repeating: 0, count: halfN)
        }
        defer { vDSP_destroy_fftsetup(setup) }

        var realBuf = [Float](repeating: 0, count: halfN)
        var imagBuf = [Float](repeating: 0, count: halfN)

        signal.withUnsafeBufferPointer { buf in
            buf.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: halfN) { cPtr in
                realBuf.withUnsafeMutableBufferPointer { rBuf in
                    imagBuf.withUnsafeMutableBufferPointer { iBuf in
                        var sc = DSPSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                        vDSP_ctoz(cPtr, 2, &sc, 1, vDSP_Length(halfN))
                    }
                }
            }
        }

        realBuf.withUnsafeMutableBufferPointer { rBuf in
            imagBuf.withUnsafeMutableBufferPointer { iBuf in
                var sc = DSPSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                vDSP_fft_zrip(setup, &sc, 1, log2n, FFTDirection(FFT_FORWARD))
            }
        }

        var mag = [Float](repeating: 0, count: halfN)
        realBuf.withUnsafeMutableBufferPointer { rBuf in
            imagBuf.withUnsafeMutableBufferPointer { iBuf in
                var sc = DSPSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                vDSP_zvmags(&sc, 1, &mag, 1, vDSP_Length(halfN))
            }
        }
        return mag
    }

    // Max-filter a spectrum along frequency bins with given half-width
    private func maxFilterSpectrum(_ spectrum: [Float], width: Int) -> [Float] {
        var result = [Float](repeating: 0, count: spectrum.count)
        for i in 0..<spectrum.count {
            let lo = max(0, i - width)
            let hi = min(spectrum.count - 1, i + width)
            result[i] = spectrum[lo...hi].max() ?? spectrum[i]
        }
        return result
    }

    // Subtract local mean (detrend)
    private func subtractLocalMean(_ signal: [Float], windowSize: Int) -> [Float] {
        guard windowSize > 0 else { return signal }
        var result = [Float](repeating: 0, count: signal.count)
        let half = windowSize / 2
        for i in 0..<signal.count {
            let lo = max(0, i - half)
            let hi = min(signal.count, i + half + 1)
            let mean = signal[lo..<hi].reduce(0, +) / Float(hi - lo)
            result[i] = signal[i] - mean
        }
        return result
    }
}


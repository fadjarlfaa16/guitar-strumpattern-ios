//
//  HybridCQT.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//

import Accelerate
import AVFoundation
import Foundation

// MARK: - HybridCQT

final class HybridCQT {

    // MARK: - Singleton
    // Menggunakan optional agar tidak fatalError jika filterbank files missing dari bundle
    static let shared: HybridCQT? = {
        do { return try HybridCQT() }
        catch {
            print("[HybridCQT] Failed to load filterbanks: \(error)")
            return nil
        }
    }()

    // MARK: - Filterbank structures

    private struct OctaveFilter {
        let loopI: Int
        let hop: Int
        let nFFT: Int
        let nHalf: Int
        let nBins: Int
        let binIndices: [Int]
        let filterReal: [Float]
        let filterImag: [Float]
    }

    private let octaveFilters: [OctaveFilter]
    private let pseudoFilter: [Float]
    private let pseudoNBins = 50
    private let pseudoNHalf = 513
    private let pseudoHop  = 512
    private let pseudoNFFT = 1024
    private let fullScale: [Float]

    private let sliceStart = 18
    private let sliceEnd   = 270
    private let outBins    = 252
    private static let preprocessingSubdirectory = "Core/Utils/Preprocessing"

    // FFT plans (one per unique n_fft size)
    private let fftSetup512: FFTSetup
    private let fftSetup1024: FFTSetup

    // Half-band anti-aliasing FIR for 2x decimation (used between octaves)
    private let halfBandFIR: [Float]

    init() throws {
        // Load per-octave filterbanks
        var octs: [OctaveFilter] = []
        for i in 0..<7 {
            let jsonURL = try Self.preprocessingURL("cqt_vqt\(i)", ext: "json")
            let binURL  = try Self.preprocessingURL("cqt_vqt\(i)", ext: "bin")

            let meta    = try Self.loadJSON(jsonURL)
            guard let hop       = meta["hop"]       as? Int,
                  let nFFT      = meta["nFFT"]      as? Int,
                  let nBins     = meta["nBins"]     as? Int,
                  let nHalf     = meta["nHalf"]     as? Int,
                  let binIdxRaw = meta["binIndices"] as? [Any] else {
                throw makeError("Invalid cqt_vqt\(i).json")
            }
            let binIndices = binIdxRaw.compactMap { v -> Int? in
                if let n = v as? Int { return n }
                if let d = v as? Double { return Int(d) }
                return nil
            }

            let raw = try Self.loadBin(binURL)
            let n = nBins * nHalf
            guard raw.count >= 2 * n else { throw makeError("cqt_vqt\(i).bin too small") }
            let fReal = Array(raw[0..<n])
            let fImag = Array(raw[n..<(2*n)])

            octs.append(OctaveFilter(loopI: i, hop: hop, nFFT: nFFT, nHalf: nHalf,
                                     nBins: nBins, binIndices: binIndices,
                                     filterReal: fReal, filterImag: fImag))
        }
        self.octaveFilters = octs

        // Load pseudo filterbank
        let pBin  = try Self.preprocessingURL("cqt_pseudo_mag", ext: "bin")
        self.pseudoFilter = try Self.loadBin(pBin)
        guard pseudoFilter.count >= pseudoNBins * pseudoNHalf else {
            throw makeError("cqt_pseudo_mag.bin too small")
        }

        // Load full-scale normalization
        let sBin = try Self.preprocessingURL("cqt_full_scale", ext: "bin")
        self.fullScale = try Self.loadBin(sBin)
        guard fullScale.count >= 238 else { throw makeError("cqt_full_scale.bin too small") }

        // FFT setups (N = 512 and 1024)
        guard let s512  = vDSP_create_fftsetup(9,  FFTRadix(kFFTRadix2)),
              let s1024 = vDSP_create_fftsetup(10, FFTRadix(kFFTRadix2)) else {
            throw makeError("vDSP_create_fftsetup failed")
        }
        fftSetup512  = s512
        fftSetup1024 = s1024

        // Generate half-band anti-aliasing FIR (129 taps, Hann-windowed sinc)
        halfBandFIR = Self.makeHalfBandFIR(length: 129)
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup512)
        vDSP_destroy_fftsetup(fftSetup1024)
    }

    
    
    func compute(samples: [Float]) throws -> [[Float]] {
        let N = samples.count
        guard N > 0 else { return [] }

        var yCur = downsample2x(samples)

        let nBinsTotal = 238
        let nFrames = 1 + yCur.count / octaveFilters[0].hop

        var fullCqtMag = [[Float]](repeating: [Float](repeating: 0, count: nFrames),
                                   count: nBinsTotal)

        for oct in octaveFilters {
            let nFFT  = oct.nFFT
            let hop   = oct.hop
            let nHalf = oct.nHalf

            let fftSetup: FFTSetup = (nFFT == 512) ? fftSetup512 : fftSetup1024

            let (stftReal, stftImag, nF) = stft(signal: yCur, nFFT: nFFT, hop: hop,
                                                 hannWindow: nil, fftSetup: fftSetup)

            let nFramesOct = min(nF, nFrames)

            let nB = oct.nBins
            var outRe = [Float](repeating: 0, count: nB * nFramesOct)
            var outIm = [Float](repeating: 0, count: nB * nFramesOct)
            let m = Int32(nB), n = Int32(nFramesOct), k = Int32(nHalf)

            outRe.withUnsafeMutableBufferPointer { outReBuf in
                outIm.withUnsafeMutableBufferPointer { outImBuf in
                    oct.filterReal.withUnsafeBufferPointer { frBuf in
                        oct.filterImag.withUnsafeBufferPointer { fiBuf in
                            stftReal.withUnsafeBufferPointer { srBuf in
                                stftImag.withUnsafeBufferPointer { siBuf in
                                    let rp = outReBuf.baseAddress!
                                    let ip = outImBuf.baseAddress!
                                    matmulAdd(m: Int(m), n: Int(n), k: Int(k),
                                             alpha: 1.0, A: frBuf.baseAddress!, strideA: Int(k),
                                             B: srBuf.baseAddress!, strideB: Int(k),
                                             beta: 0.0, C: rp, strideC: Int(n))
                                    matmulAdd(m: Int(m), n: Int(n), k: Int(k),
                                             alpha: -1.0, A: fiBuf.baseAddress!, strideA: Int(k),
                                             B: siBuf.baseAddress!, strideB: Int(k),
                                             beta: 1.0, C: rp, strideC: Int(n))
                                    matmulAdd(m: Int(m), n: Int(n), k: Int(k),
                                             alpha: 1.0, A: frBuf.baseAddress!, strideA: Int(k),
                                             B: siBuf.baseAddress!, strideB: Int(k),
                                             beta: 0.0, C: ip, strideC: Int(n))
                                    matmulAdd(m: Int(m), n: Int(n), k: Int(k),
                                             alpha: 1.0, A: fiBuf.baseAddress!, strideA: Int(k),
                                             B: srBuf.baseAddress!, strideB: Int(k),
                                             beta: 1.0, C: ip, strideC: Int(n))
                                }
                            }
                        }
                    }
                }
            }

            for b in 0..<nB {
                let globalBin = oct.binIndices[b]
                guard globalBin < nBinsTotal else { continue }
                for f in 0..<nFramesOct {
                    let re = outRe[b * nFramesOct + f]
                    let im = outIm[b * nFramesOct + f]
                    fullCqtMag[globalBin][f] = sqrtf(re * re + im * im)
                }
            }

            if oct.loopI < 6 {
                yCur = downsample2x(yCur)
            }
        }

        for b in 0..<nBinsTotal {
            guard b < fullScale.count else { break }
            let s = fullScale[b]
            for f in 0..<nFrames {
                fullCqtMag[b][f] *= s
            }
        }

        let hannWin = makeHannWindow(length: pseudoNFFT)
        let (stftMag, _, nFPseudo) = stftMagnitude(signal: samples, nFFT: pseudoNFFT,
                                                    hop: pseudoHop, hannWindow: hannWin,
                                                    fftSetup: fftSetup1024)
        let nFP = min(nFPseudo, nFrames)

        var pseudoCqtMag = [[Float]](repeating: [Float](repeating: 0, count: nFrames),
                                     count: pseudoNBins)

        var pseudoOut = [Float](repeating: 0, count: pseudoNBins * nFP)
        pseudoOut.withUnsafeMutableBufferPointer { outBuf in
            pseudoFilter.withUnsafeBufferPointer { fBuf in
                stftMag.withUnsafeBufferPointer { sBuf in
                    matmulAdd(m: pseudoNBins, n: nFP, k: pseudoNHalf,
                             alpha: 1.0, A: fBuf.baseAddress!, strideA: pseudoNHalf,
                             B: sBuf.baseAddress!, strideB: pseudoNHalf,
                             beta: 0.0, C: outBuf.baseAddress!, strideC: nFP)
                }
            }
        }
        for b in 0..<pseudoNBins {
            for f in 0..<nFP {
                pseudoCqtMag[b][f] = pseudoOut[b * nFP + f]
            }
        }

        let finalFrames = min(nFrames, nFPseudo)
        var result = [[Float]](repeating: [Float](repeating: 0, count: outBins),
                               count: finalFrames)

        for f in 0..<finalFrames {
            for outB in 0..<outBins {
                let globalB = sliceStart + outB
                if globalB < nBinsTotal {
                    result[f][outB] = fullCqtMag[globalB][f]
                } else {
                    let pseudoB = globalB - nBinsTotal
                    if pseudoB < pseudoNBins {
                        result[f][outB] = pseudoCqtMag[pseudoB][f]
                    }
                }
            }
        }

        return result
    }

    // MARK: - Matrix Multiplication

    /// Performs row-major matrix multiplication: C = alpha * A @ B^T + beta * C
    /// - Parameters:
    ///   - m: number of rows in A and C
    ///   - n: number of rows in B (= columns of B^T)
    ///   - k: number of columns in A (= columns in B)
    ///   - alpha: scalar multiplier for A @ B^T
    ///   - A: row-major matrix [m × k]
    ///   - B: row-major matrix [n × k]
    ///   - beta: scalar multiplier for C
    ///   - C: row-major output matrix [m × n] (modified in-place)
    private func matmulAdd(m: Int, n: Int, k: Int,
                          alpha: Float, A: UnsafePointer<Float>, strideA: Int,
                          B: UnsafePointer<Float>, strideB: Int,
                          beta: Float, C: UnsafeMutablePointer<Float>, strideC: Int) {
        cblas_sgemm(
            CblasRowMajor,
            CblasNoTrans,
            CblasTrans,
            Int32(m),
            Int32(n),
            Int32(k),
            alpha,
            A,
            Int32(strideA),
            B,
            Int32(strideB),
            beta,
            C,
            Int32(strideC)
        )
    }

    private func stft(signal: [Float], nFFT: Int, hop: Int,
                      hannWindow: [Float]?, fftSetup: FFTSetup) -> ([Float], [Float], Int) {
        let N = signal.count
        let pad = nFFT / 2
        let nHalf = nFFT / 2 + 1
        let nFrames = 1 + N / hop

        var padded = [Float](repeating: 0, count: N + 2 * pad)
        padded.withUnsafeMutableBufferPointer { dst in
            signal.withUnsafeBufferPointer { src in
                (dst.baseAddress! + pad).initialize(from: src.baseAddress!, count: N)
            }
        }

        let totalCount = nFrames * nHalf
        var outReal = [Float](repeating: 0, count: totalCount)
        var outImag = [Float](repeating: 0, count: totalCount)

        var realBuf = [Float](repeating: 0, count: nFFT / 2)
        var imagBuf = [Float](repeating: 0, count: nFFT / 2)

        for t in 0..<nFrames {
            let start = t * hop
            var frame = [Float](repeating: 0, count: nFFT)
            let available = min(nFFT, padded.count - start)
            if available > 0 {
                frame.withUnsafeMutableBufferPointer { dst in
                    padded.withUnsafeBufferPointer { src in
                        (dst.baseAddress!).initialize(from: src.baseAddress! + start,
                                                      count: available)
                    }
                }
            }

            if let win = hannWindow {
                vDSP_vmul(frame, 1, win, 1, &frame, 1, vDSP_Length(nFFT))
            }

            frame.withUnsafeBufferPointer { buf in
                buf.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: nFFT / 2) { cPtr in
                    realBuf.withUnsafeMutableBufferPointer { rBuf in
                        imagBuf.withUnsafeMutableBufferPointer { iBuf in
                            var sc = DSPSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                            vDSP_ctoz(cPtr, 2, &sc, 1, vDSP_Length(nFFT / 2))
                        }
                    }
                }
            }

            realBuf.withUnsafeMutableBufferPointer { rBuf in
                imagBuf.withUnsafeMutableBufferPointer { iBuf in
                    var sc = DSPSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                    vDSP_fft_zrip(fftSetup, &sc, 1, vDSP_Length(log2(Float(nFFT))), FFTDirection(FFT_FORWARD))
                }
            }

            let base = t * nHalf
            outReal[base]           = realBuf[0] * 0.5
            outImag[base]           = 0.0
            outReal[base + nHalf-1] = imagBuf[0] * 0.5
            outImag[base + nHalf-1] = 0.0
            for k in 1..<(nHalf - 1) {
                outReal[base + k] = realBuf[k] * 0.5
                outImag[base + k] = imagBuf[k] * 0.5
            }
        }

        return (outReal, outImag, nFrames)
    }

    private func stftMagnitude(signal: [Float], nFFT: Int, hop: Int,
                                hannWindow: [Float], fftSetup: FFTSetup) -> ([Float], [Float], Int) {
        let (real, imag, nFrames) = stft(signal: signal, nFFT: nFFT, hop: hop,
                                          hannWindow: hannWindow, fftSetup: fftSetup)
        let nHalf = nFFT / 2 + 1
        let total = nFrames * nHalf
        var mag = [Float](repeating: 0, count: total)
        for i in 0..<total {
            mag[i] = sqrtf(real[i] * real[i] + imag[i] * imag[i])
        }
        return (mag, [], nFrames)
    }

    private func downsample2x(_ signal: [Float]) -> [Float] {
        guard !signal.isEmpty else { return [] }
        let M    = halfBandFIR.count
        let halfM = M / 2

        let padded = [Float](repeating: 0, count: halfM) + signal
                   + [Float](repeating: 0, count: halfM)
        let outLen = padded.count - M + 1   // == signal.count

        var convOut = [Float](repeating: 0, count: outLen)
        halfBandFIR.withUnsafeBufferPointer { hBuf in
            padded.withUnsafeBufferPointer { pBuf in
                guard let pBase = pBuf.baseAddress,
                      let hBase = hBuf.baseAddress else { return }
                // IF = -1, starting at last tap → true convolution (not correlation)
                vDSP_conv(pBase, 1,
                          hBase + (M - 1), -1,
                          &convOut, 1,
                          vDSP_Length(outLen), vDSP_Length(M))
            }
        }

        // Decimate by 2
        let decimatedLen = outLen / 2
        var result = [Float](repeating: 0, count: decimatedLen)
        for i in 0..<decimatedLen {
            result[i] = convOut[i * 2]
        }

        // Apply √2 to match librosa.resample(scale=True)
        var sqrtTwo = Float(sqrt(2.0))
        vDSP_vsmul(result, 1, &sqrtTwo, &result, 1, vDSP_Length(decimatedLen))
        return result
    }

    // MARK: - Hann window

    private func makeHannWindow(length: Int) -> [Float] {
        var w = [Float](repeating: 0, count: length)
        // Periodic Hann: w[n] = 0.5 * (1 - cos(2π*n/N))  for n=0..N-1
        for n in 0..<length {
            w[n] = 0.5 * (1.0 - cosf(2.0 * .pi * Float(n) / Float(length)))
        }
        return w
    }

    // MARK: - Half-band FIR design

    /// Creates a symmetric Hann-windowed sinc half-band FIR filter for 2× decimation.
    private static func makeHalfBandFIR(length: Int) -> [Float] {
        precondition(length % 2 == 1, "Filter length must be odd for symmetric linear-phase FIR")
        let center = length / 2
        var h = [Float](repeating: 0, count: length)
        let fc = 0.25

        for n in 0..<length {
            let k = n - center
            let sincVal: Double
            if k == 0 {
                sincVal = 2.0 * fc
            } else {
                let arg = Double.pi * Double(k) * 2.0 * fc
                sincVal = sin(arg) / (Double.pi * Double(k))
            }
            let hannVal = 0.5 * (1.0 - cos(2.0 * Double.pi * Double(n) / Double(length - 1)))
            h[n] = Float(sincVal * hannVal)
        }

        let dcGain = h.reduce(0.0, { $0 + Double($1) })
        if dcGain > 1e-12 {
            for i in 0..<length { h[i] /= Float(dcGain) }
        }

        return h
    }


    private static func preprocessingURL(_ name: String, ext: String) throws -> URL {
        let subdirectories = [
            preprocessingSubdirectory,
            nil as String?,
        ]
        for sub in subdirectories {
            if let sub,
               let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: sub) {
                return url
            }
            if sub == nil, let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        throw makeError("\(name).\(ext) not found in bundle.")
    }

    private static func loadBin(_ url: URL) throws -> [Float] {
        let data = try Data(contentsOf: url)
        return data.withUnsafeBytes { buf in
            Array(buf.bindMemory(to: Float.self))
        }
    }

    private static func loadJSON(_ url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw makeError("Invalid JSON at \(url.lastPathComponent)")
        }
        return obj
    }
}

private func makeError(_ msg: String) -> NSError {
    NSError(domain: "HybridCQT", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
}

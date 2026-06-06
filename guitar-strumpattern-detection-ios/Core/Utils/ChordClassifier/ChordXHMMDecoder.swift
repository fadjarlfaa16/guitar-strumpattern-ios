//
//  ChordXHMMDecoder.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//

import CoreML
import Foundation

final class ChordXHMMDecoder {

    private let entries: [ChordEntry]
    private let diffTransPenalty: Float

    private let bassAdjusted: [Int]
    private let triadIndices: [Int]
    private let seventhIndices: [Int]
    private let ninthIndices: [Int]
    private let eleventhIndices: [Int]
    private let thirteenthIndices: [Int]

    init(mapping: ChordMapping, diffTransPenalty: Float = 30.0) {
        self.entries = mapping.entries
        self.diffTransPenalty = diffTransPenalty

        triadIndices     = entries.map { $0.triad }
        bassAdjusted     = entries.map { $0.bass + 1 }
        seventhIndices   = entries.map { $0.seventh }
        ninthIndices     = entries.map { $0.ninth }
        eleventhIndices  = entries.map { $0.eleventh }
        thirteenthIndices = entries.map { $0.thirteenth }
    }

    func decode(
        triad: MLMultiArray,
        bass: MLMultiArray,
        seventh: MLMultiArray,
        ninth: MLMultiArray,
        eleventh: MLMultiArray,
        thirteenth: MLMultiArray
    ) -> (indices: [Int], labels: [String])? {

        let nChords = entries.count
        guard nChords > 0 else { return nil }

        // Extract frame count and column counts from shapes
        guard let (nFrames, triadCols) = dims2D(triad),
              let (_, bassCols)        = dims2D(bass),
              let (_, seventhCols)     = dims2D(seventh),
              let (_, ninthCols)       = dims2D(ninth),
              let (_, eleventhCols)    = dims2D(eleventh),
              let (_, thirteenthCols)  = dims2D(thirteenth),
              nFrames > 0 else { return nil }

        let triadPtr      = floatPtr(triad)
        let bassPtr       = floatPtr(bass)
        let seventhPtr    = floatPtr(seventh)
        let ninthPtr      = floatPtr(ninth)
        let eleventhPtr   = floatPtr(eleventh)
        let thirteenthPtr = floatPtr(thirteenth)

        let logFloor: Float = 1e-10
        let negInf: Float = -.greatestFiniteMagnitude

        var logProb = [Float](repeating: negInf, count: nFrames * nChords)

        for f in 0..<nFrames {
            let tRow  = f * triadCols
            let bRow  = f * bassCols
            let s7Row = f * seventhCols
            let s9Row = f * ninthCols
            let s11Row = f * eleventhCols
            let s13Row = f * thirteenthCols

            for c in 0..<nChords {
                let ti = triadIndices[c]
                guard ti >= 0, ti < triadCols else { continue }

                var lp = logf(max(triadPtr[tRow + ti], logFloor))

                let bi = bassAdjusted[c]
                if bi >= 0, bi < bassCols {
                    lp += logf(max(bassPtr[bRow + bi], logFloor))
                }

                let si7 = seventhIndices[c]
                if si7 >= 0, si7 < seventhCols {
                    lp += logf(max(seventhPtr[s7Row + si7], logFloor))
                }

                let si9 = ninthIndices[c]
                if si9 >= 0, si9 < ninthCols {
                    lp += logf(max(ninthPtr[s9Row + si9], logFloor))
                }

                let si11 = eleventhIndices[c]
                if si11 >= 0, si11 < eleventhCols {
                    lp += logf(max(eleventhPtr[s11Row + si11], logFloor))
                }

                let si13 = thirteenthIndices[c]
                if si13 >= 0, si13 < thirteenthCols {
                    lp += logf(max(thirteenthPtr[s13Row + si13], logFloor))
                }

                logProb[f * nChords + c] = lp
            }
        }

        var dp  = [Float](repeating: negInf, count: nFrames * nChords)
        var pre = [Int](repeating: 0,        count: nFrames * nChords)

        dp[0] = logProb[0]
        for c in 1..<nChords { dp[c] = negInf }

        var dpMaxAt = [Int](repeating: 0, count: nFrames)
        dpMaxAt[0] = 0

        for t in 1..<nFrames {
            let prevBase = (t - 1) * nChords
            let curBase  = t * nChords

            let bestPrevScore = dp[prevBase + dpMaxAt[t - 1]]
            let diffTransScore = bestPrevScore - diffTransPenalty
            let bestPrevChord = dpMaxAt[t - 1]

            var maxDp = negInf
            var maxIdx = 0

            for c in 0..<nChords {
                let sameScore = dp[prevBase + c]
                let (chosenScore, chosenPrev): (Float, Int)
                if sameScore >= diffTransScore {
                    chosenScore = sameScore
                    chosenPrev = c
                } else {
                    chosenScore = diffTransScore
                    chosenPrev = bestPrevChord
                }
                let newDp = chosenScore + logProb[curBase + c]
                dp[curBase + c] = newDp
                pre[curBase + c] = chosenPrev
                if newDp > maxDp {
                    maxDp = newDp
                    maxIdx = c
                }
            }
            dpMaxAt[t] = maxIdx
        }

        var sequence = [Int](repeating: 0, count: nFrames)
        sequence[nFrames - 1] = dpMaxAt[nFrames - 1]
        for t in stride(from: nFrames - 2, through: 0, by: -1) {
            sequence[t] = pre[(t + 1) * nChords + sequence[t + 1]]
        }

        let labels = sequence.map { entries[$0].label }

        return (sequence, labels)
    }

    private func dims2D(_ array: MLMultiArray) -> (Int, Int)? {
        let s = array.shape.map { Int(truncating: $0) }
        if s.count == 2 {
            return (s[0], s[1])
        } else if s.count == 3, s[0] == 1 {
            return (s[1], s[2])
        } else if s.count >= 2 {
            return (s[s.count - 2], s[s.count - 1])
        }
        return nil
    }

    private func floatPtr(_ array: MLMultiArray) -> UnsafePointer<Float> {
        if array.dataType == .float32 {
            return UnsafePointer(array.dataPointer.bindMemory(to: Float.self, capacity: array.count))
        }
        fatalError("ChordXHMMDecoder: expected float32 MLMultiArray")
    }
}

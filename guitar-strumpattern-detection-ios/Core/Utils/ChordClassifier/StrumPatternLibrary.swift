//
//  StrumPatternLibrary.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 13/06/26.
//

import Foundation

enum StrumPatternLibrary {
    private struct LibraryPattern: Decodable {
        let id: Int?
        let pattern: String
        let bpm: [Int]
        let chordRate: Double?
        let chordRateMin: Double?
        let chordRateMax: Double?

        enum CodingKeys: String, CodingKey {
            case id
            case pattern
            case bpm
            case chordRate = "chord_rate"
            case chordRateMin = "chord_rate_min"
            case chordRateMax = "chord_rate_max"
        }
    }

    static func recommendations(
        bpm: Int,
        timeSignature: String,
        chordSegments: [StoredChordSegment],
        limit: Int = 4
    ) -> [StrummingPattern] {
        let source = loadPatterns()
        guard !source.isEmpty else { return [] }

        let stats = SongRhythmStats(
            bpm: bpm,
            timeSignature: timeSignature,
            chordSegments: chordSegments
        )

        return source
            .map { entry in
                let score = score(entry, stats: stats)
                return StrummingPattern(
                    label: entry.pattern,
                    libraryID: entry.id,
                    matchScore: score
                )
            }
            .sorted {
                if $0.matchScore == $1.matchScore {
                    return ($0.libraryID ?? Int.max) < ($1.libraryID ?? Int.max)
                }
                return ($0.matchScore ?? 0) > ($1.matchScore ?? 0)
            }
            .prefix(limit)
            .map { $0 }
    }

    static func allPatterns() -> [StrummingPattern] {
        loadPatterns().map {
            StrummingPattern(label: $0.pattern, libraryID: $0.id)
        }
    }

    private static func loadPatterns() -> [LibraryPattern] {
        let decoder = JSONDecoder()

        if let url = Bundle.main.url(forResource: "strumPattern", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([LibraryPattern].self, from: data) {
            return decoded
        }

        let localURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("strumPattern.json")
        guard let data = try? Data(contentsOf: localURL),
              let decoded = try? decoder.decode([LibraryPattern].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func score(_ pattern: LibraryPattern, stats: SongRhythmStats) -> Double {
        let bpmScore = scoreBPM(stats.bpm, range: pattern.bpm)
        let chordRateScore = scoreChordRate(pattern, medianBeatsPerChord: stats.medianBeatsPerChord)
        let densityScore = scoreDensity(pattern.pattern, stats: stats)
        let phraseScore = scorePhraseFit(pattern.pattern, stats: stats)

        return bpmScore * 0.35
            + chordRateScore * 0.35
            + densityScore * 0.15
            + phraseScore * 0.15
    }

    private static func scoreBPM(_ bpm: Int, range: [Int]) -> Double {
        guard range.count >= 2 else { return 0.5 }
        let value = Double(bpm)
        let minBPM = Double(range[0])
        let maxBPM = Double(range[1])
        if value >= minBPM && value <= maxBPM { return 1.0 }

        let distance = value < minBPM ? minBPM - value : value - maxBPM
        return max(0.0, 1.0 - distance / 40.0)
    }

    private static func scoreChordRate(_ pattern: LibraryPattern, medianBeatsPerChord: Double) -> Double {
        if let exact = pattern.chordRate {
            let distance = abs(medianBeatsPerChord - exact)
            return max(0.0, 1.0 - distance / max(exact, 1.0))
        }

        let minRate = pattern.chordRateMin ?? 1
        let maxRate = pattern.chordRateMax ?? minRate
        if medianBeatsPerChord >= minRate && medianBeatsPerChord <= maxRate { return 1.0 }

        let distance = medianBeatsPerChord < minRate
            ? minRate - medianBeatsPerChord
            : medianBeatsPerChord - maxRate
        return max(0.0, 1.0 - distance / max(maxRate, 1.0))
    }

    private static func scoreDensity(_ notation: String, stats: SongRhythmStats) -> Double {
        let beats = StrummingPattern(label: notation).beats
        guard !beats.isEmpty else { return 0 }

        let realStrums = Double(beats.filter { $0.direction != nil }.count)
        let density = realStrums / Double(beats.count)
        let targetDensity = stats.medianBeatsPerChord <= 1.5 ? 0.55 : 0.7
        return max(0.0, 1.0 - abs(density - targetDensity) / 0.45)
    }

    private static func scorePhraseFit(_ notation: String, stats: SongRhythmStats) -> Double {
        let slotCount = StrummingPattern(label: notation).beats.count
        guard slotCount > 0 else { return 0 }

        let slotsPerMeasure = max(1, stats.numerator * 2)
        if slotCount == slotsPerMeasure { return 1.0 }
        if slotCount % slotsPerMeasure == 0 || slotsPerMeasure % slotCount == 0 { return 0.85 }

        let remainder = min(slotCount % slotsPerMeasure, slotsPerMeasure % slotCount)
        return max(0.35, 1.0 - Double(remainder) / Double(slotsPerMeasure))
    }
}

private struct SongRhythmStats {
    let bpm: Int
    let numerator: Int
    let medianBeatsPerChord: Double

    init(bpm: Int, timeSignature: String, chordSegments: [StoredChordSegment]) {
        self.bpm = bpm > 0 ? bpm : 120

        let parsed = ChordGroup.parseTimeSignature(timeSignature)
        self.numerator = parsed.numerator

        let beatDuration = 60.0 / Double(self.bpm)
        let durations = chordSegments
            .filter { $0.label != "N" }
            .map { max(0, $0.endTime - $0.startTime) / beatDuration }
            .filter { $0.isFinite && $0 > 0 }
            .sorted()

        if durations.isEmpty {
            self.medianBeatsPerChord = Double(parsed.numerator)
        } else {
            let mid = durations.count / 2
            if durations.count.isMultiple(of: 2) {
                self.medianBeatsPerChord = (durations[mid - 1] + durations[mid]) / 2
            } else {
                self.medianBeatsPerChord = durations[mid]
            }
        }
    }
}

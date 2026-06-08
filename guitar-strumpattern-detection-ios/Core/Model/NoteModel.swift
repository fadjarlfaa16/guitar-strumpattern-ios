//
//  NoteModel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import Foundation

// MARK: - Strum Notifier

public enum StrumNotifier {
    public static let strumUpNotification = Notification.Name("StrumUpNotification")
    public static let strumDownNotification = Notification.Name("StrumDownNotification")

    public static func triggerStrumUp() {
        NotificationCenter.default.post(name: strumUpNotification, object: nil)
    }

    public static func triggerStrumDown() {
        NotificationCenter.default.post(name: strumDownNotification, object: nil)
    }
}

// MARK: - Strum Beat

/// A single beat in a repeating strumming pattern.
enum StrumBeat: String, CaseIterable {
    case down    = "D"   // strum down
    case up      = "U"   // strum up
    case noStrum = "N"   // silent beat — occupies time but spawns no note

    /// Returns "up" / "down", or nil for noStrum.
    var direction: String? {
        switch self {
        case .down:    return "down"
        case .up:      return "up"
        case .noStrum: return nil
        }
    }
}

// MARK: - Hit Result

enum HitResult {
    case perfect
    case good
    case miss
}

// MARK: - Note Input

/// A single strum note placed at a specific timestamp, belonging to a chord group.
struct NoteInput: Identifiable {
    let id: UUID
    /// Seconds from the start of the session when this note should be hit.
    /// This is the BPM-derived time and directly controls its visual position.
    let time: TimeInterval
    /// Strum direction — "up" or "down".
    let direction: String
    /// Parent chord name (e.g. "Am").
    let chord: String
    /// Which ChordGroup this belongs to.
    let groupId: UUID
    /// True for the first note in its group.
    let isGroupLeader: Bool
    /// 0-based index within the group (only counting real notes, not N beats).
    let indexInGroup: Int

    init(
        id: UUID = UUID(),
        time: TimeInterval,
        direction: String,
        chord: String,
        groupId: UUID,
        isGroupLeader: Bool,
        indexInGroup: Int
    ) {
        self.id             = id
        self.time           = time
        self.direction      = direction
        self.chord          = chord
        self.groupId        = groupId
        self.isGroupLeader  = isGroupLeader
        self.indexInGroup   = indexInGroup
    }
}

// MARK: - Chord Group

/// One chord and all the strum notes that belong to it.
struct ChordGroup: Identifiable {
    let id: UUID
    let chord: String
    let notes: [NoteInput]

    /// Time of the first note in the group.
    var startTime: TimeInterval { notes.first?.time ?? 0 }
    /// Time of the last note in the group.
    var endTime:   TimeInterval { notes.last?.time  ?? 0 }

    init(id: UUID = UUID(), chord: String, notes: [NoteInput]) {
        self.id    = id
        self.chord = chord
        self.notes = notes
    }
}

// MARK: - Active Note (runtime)

struct ActiveNote: Identifiable {
    let id: UUID
    let input: NoteInput
    var isHit:     Bool       = false
    var isExpired: Bool       = false
    var hitResult: HitResult? = nil
}

// MARK: - Time Signature Parser

extension ChordGroup {
    /// Parses "4/4", "3/4", "6/8" etc. Falls back to (4, 4).
    static func parseTimeSignature(_ ts: String) -> (numerator: Int, denominator: Int) {
        let parts = ts.split(separator: "/").compactMap { Int($0) }
        guard parts.count == 2, parts[0] > 0, parts[1] > 0 else { return (4, 4) }
        return (parts[0], parts[1])
    }
    
    /// Parses "MM:SS" (e.g., "3:00") into seconds.
    static func parseDuration(_ durationStr: String) -> TimeInterval? {
        let parts = durationStr.split(separator: ":")
        if parts.count == 2, let m = Double(parts[0]), let s = Double(parts[1]) {
            return m * 60 + s
        }
        return nil
    }
}

// MARK: - Builder

extension ChordGroup {

    /// Expands `[ChordSegment]` × pattern × BPM × time-signature → `[ChordGroup]`.
    ///
    /// **Timing rules:**
    ///  - Each group starts at `segment.startTime`.
    ///  - Beats are spaced `(60/bpm) × (4/denominator)` seconds apart.
    ///  - `.noStrum` advances the clock but spawns no note block.
    ///    Its empty time slot produces a visible gap in the lane.
    ///  - **Overlap prevention:** If a note would land at or after the *next*
    ///    chord segment's `startTime`, that note (and all subsequent beats)
    ///    are dropped to prevent visual overlap between groups.
    ///
    /// **Visual positioning:**
    ///  Notes are positioned purely by their `time` value — the BPM directly
    ///  controls the on-screen spacing between notes. Faster BPM = tighter
    ///  spacing, slower BPM = wider spacing.
    static func build(
        chords: [ChordSegment],
        pattern: [StrumBeat],
        bpm: Int,
        timeSignature: String = "4/4",
        duration: String? = nil
    ) -> [ChordGroup] {
        guard !chords.isEmpty, !pattern.isEmpty, bpm > 0 else { return [] }

        let (_, denom) = parseTimeSignature(timeSignature)
        let beatDuration = (60.0 / Double(bpm)) * (4.0 / Double(denom))
        var groups: [ChordGroup] = []
        
        let durationTime = duration.flatMap { parseDuration($0) }
        var processedChords = chords
        
        // Loop the chords sequence if a duration limit is provided
        if let limit = durationTime, let first = chords.first, let last = chords.last {
            let seqLen = last.endTime - first.startTime
            var currentOffset: TimeInterval = 0
            var repeated: [ChordSegment] = []
            
            while (first.startTime + currentOffset) < limit {
                for seg in chords {
                    let start = seg.startTime + currentOffset
                    if start >= limit { break }
                    repeated.append(ChordSegment(
                        startTime: start,
                        endTime: seg.endTime + currentOffset,
                        label: seg.label
                    ))
                }
                currentOffset += seqLen
                if seqLen <= 0 { break } // Fallback to prevent infinite loop
            }
            processedChords = repeated
        }

        let firstStart = processedChords.first?.startTime ?? 0

        for (segIdx, segment) in processedChords.enumerated() {
            let gid = UUID()
            var notes: [NoteInput] = []
            
            // Snap the start time to the nearest beat on the global grid
            // This prevents chords that fall on half-beats (like 3.5s at 60 BPM) 
            // from forcing the strum pattern completely off-beat.
            let relative = segment.startTime - firstStart
            let beatsElapsed = round(relative / beatDuration)
            var clock = firstStart + beatsElapsed * beatDuration
            
            var idx = 0

            // The boundary: notes must not reach into the next chord's territory
            let nextStart: TimeInterval
            if segIdx + 1 < processedChords.count {
                let nextRelative = processedChords[segIdx + 1].startTime - firstStart
                let nextBeats = round(nextRelative / beatDuration)
                nextStart = firstStart + nextBeats * beatDuration
            } else {
                nextStart = .infinity   // last segment — no limit
            }

            for beat in pattern {
                // Stop if this note would visually overlap with the next
                // chord group. Uses a fixed 0.3s buffer (≈ one block width
                // in time on typical screens) — unlike the old beatDuration
                // guard which was too aggressive at slow BPMs.
                let minGroupGap: TimeInterval = 0.3
                if clock + minGroupGap >= nextStart { break }
                
                // Stop if we exceed the requested duration
                if let limit = durationTime, clock >= limit { break }

                if let dir = beat.direction {
                    notes.append(NoteInput(
                        time: clock,
                        direction: dir,
                        chord: segment.label,
                        groupId: gid,
                        isGroupLeader: idx == 0,
                        indexInGroup: idx
                    ))
                    idx += 1
                }
                clock += beatDuration
            }

            if !notes.isEmpty {
                groups.append(ChordGroup(id: gid, chord: segment.label, notes: notes))
            }
        }
        return groups
    }
}

// MARK: - Sample Data

extension ChordGroup {
    static let samplePattern:       [StrumBeat] = [.down, .up, .down, .noStrum, .down]
    static let sampleTimeSignature: String      = "4/4"
    static let sampleSegments: [ChordSegment] = [
        ChordSegment(startTime: 1.0,  endTime: 3.5,  label: "Am"),
        ChordSegment(startTime: 3.5,  endTime: 6.0,  label: "G"),
        ChordSegment(startTime: 6.0,  endTime: 8.5,  label: "C"),
        ChordSegment(startTime: 8.5,  endTime: 11.0, label: "Em"),
    ]

    static var sampleGroups: [ChordGroup] {
        build(chords: sampleSegments,
              pattern: samplePattern,
              bpm: 120,
              timeSignature: sampleTimeSignature)
    }
}

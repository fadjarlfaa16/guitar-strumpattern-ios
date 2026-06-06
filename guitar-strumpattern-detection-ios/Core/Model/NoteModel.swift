//
//  NoteModel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import Foundation

// MARK: - Note Input Model
/// A single note in the strum pattern, placed at a specific timestamp.
struct NoteInput: Identifiable {
    let id = UUID()
    /// Seconds from the start of the song when this note should be hit.
    let time: TimeInterval
    /// Strum direction — "up" or "down".
    let direction: String
}

// MARK: - Hit Result
enum HitResult {
    case perfect
    case good
    case miss
}

// MARK: - Active Note (runtime)
/// A note that is currently active on screen during gameplay.
struct ActiveNote: Identifiable {
    let id: UUID
    let input: NoteInput
    /// Whether the player has already interacted with this note.
    var isHit: Bool = false
    /// Whether this note has scrolled past the hit zone without being hit.
    var isExpired: Bool = false
    /// The hit result, set when the player taps at the right moment.
    var hitResult: HitResult? = nil
}

// MARK: - Hardcoded Sample Pattern
extension NoteInput {
    /// Sample strum pattern at 120 BPM in 4/4 time.
    /// Each beat is 0.5s apart (120 BPM = 0.5s per beat).
    static let samplePattern: [NoteInput] = [
        NoteInput(time: 0.5,  direction: "down"),
        NoteInput(time: 1.0,  direction: "down"),
        NoteInput(time: 1.5,  direction: "up"),
        NoteInput(time: 2.0,  direction: "down"),
        NoteInput(time: 2.5,  direction: "up"),
        NoteInput(time: 3.0,  direction: "up"),
        NoteInput(time: 3.5,  direction: "down"),
        NoteInput(time: 4.0,  direction: "up"),
        NoteInput(time: 4.5,  direction: "down"),
        NoteInput(time: 5.0,  direction: "down"),
        NoteInput(time: 5.5,  direction: "up"),
        NoteInput(time: 6.0,  direction: "down"),
        NoteInput(time: 6.5,  direction: "up"),
        NoteInput(time: 7.0,  direction: "down"),
        NoteInput(time: 7.5,  direction: "up"),
        NoteInput(time: 8.0,  direction: "down"),
    ]
}

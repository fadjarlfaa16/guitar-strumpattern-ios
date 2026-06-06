//
//  RhythmGameViewModel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Timing Windows
private enum TimingWindow {
    static let perfect: TimeInterval = 0.08   // ±80ms
    static let good: TimeInterval    = 0.15   // ±150ms
}

// MARK: - ViewModel
@MainActor
class RhythmGameViewModel: ObservableObject {

    // MARK: Published State
    @Published var activeNotes: [ActiveNote] = []
    @Published var score: Int = 0
    @Published var combo: Int = 0
    @Published var lastHitResult: HitResult? = nil
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var isFinished: Bool = false

    // MARK: Configuration
    /// BPM — used for display/audio sync. Note timings are driven by NoteInput.time directly.
    var bpm: Int
    /// The full note pattern for this session.
    private(set) var pattern: [NoteInput]

    // MARK: Layout Constants
    /// How many seconds before its hit time a note should appear on the right edge.
    let travelDuration: TimeInterval = 2.5
    /// Fraction of screen width from the left where the hit zone sits.
    static let hitZoneFraction: CGFloat = 0.20

    // MARK: Private
    private var timer: Timer?
    private var startDate: Date?
    private var pendingNotes: [NoteInput] = []
    private var feedbackResetTask: Task<Void, Never>? = nil

    // MARK: Init
    init(pattern: [NoteInput] = NoteInput.samplePattern, bpm: Int = 120) {
        self.pattern = pattern
        self.bpm = bpm
    }

    // MARK: - Game Control

    func startGame() {
        reset()
        pendingNotes = pattern.sorted { $0.time < $1.time }
        startDate = Date()
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func stopGame() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }

    func reset() {
        stopGame()
        activeNotes = []
        score = 0
        combo = 0
        lastHitResult = nil
        currentTime = 0
        isFinished = false
        pendingNotes = []
        startDate = nil
    }

    // MARK: - Game Loop

    private func tick() {
        guard let startDate else { return }
        currentTime = Date().timeIntervalSince(startDate)

        // Spawn notes that should become visible now
        // A note appears (travelDuration) seconds before its target hit time
        let spawnThreshold = currentTime + travelDuration
        while let next = pendingNotes.first, next.time <= spawnThreshold {
            let note = ActiveNote(id: next.id, input: next)
            activeNotes.append(note)
            pendingNotes.removeFirst()
        }

        // Expire notes that are too far past the hit zone (more than good window)
        for i in activeNotes.indices {
            let note = activeNotes[i]
            guard !note.isHit && !note.isExpired else { continue }
            let delta = currentTime - note.input.time
            if delta > TimingWindow.good + 0.05 {
                activeNotes[i].isExpired = true
                activeNotes[i].hitResult = .miss
                combo = 0
                triggerFeedback(.miss)
            }
        }

        // Clean up notes that are fully off the left side of the screen
        activeNotes.removeAll { note in
            note.isExpired && (currentTime - note.input.time) > travelDuration
        }

        // Check if the game has ended
        if pendingNotes.isEmpty && activeNotes.isEmpty && currentTime > (pattern.last?.time ?? 0) + travelDuration {
            stopGame()
            isFinished = true
        }
    }

    // MARK: - Player Action

    /// Called when the player strums up or down.
    /// - Parameter direction: The strum direction — "up" or "down".
    func onAction(direction: String) {
        guard isPlaying else { return }

        // Find the closest unhit note to the current time (within the good window)
        let candidates = activeNotes
            .filter { !$0.isHit && !$0.isExpired }
            .sorted { abs($0.input.time - currentTime) < abs($1.input.time - currentTime) }

        guard let closest = candidates.first,
              let idx = activeNotes.firstIndex(where: { $0.id == closest.id }) else {
            // No note nearby — free miss
            combo = 0
            triggerFeedback(.miss)
            return
        }

        let delta = abs(closest.input.time - currentTime)

        // Wrong direction always counts as a miss
        guard closest.input.direction == direction else {
            combo = 0
            triggerFeedback(.miss)
            return
        }

        if delta <= TimingWindow.perfect {
            register(index: idx, result: .perfect)
        } else if delta <= TimingWindow.good {
            register(index: idx, result: .good)
        } else {
            // In-window note exists but timing is off
            combo = 0
            triggerFeedback(.miss)
        }
    }

    // MARK: - Helpers

    private func register(index: Int, result: HitResult) {
        activeNotes[index].isHit = true
        activeNotes[index].hitResult = result
        activeNotes[index].isExpired = true

        switch result {
        case .perfect:
            score += 300
            combo += 1
        case .good:
            score += 100
            combo += 1
        case .miss:
            combo = 0
        }

        triggerFeedback(result)
    }

    private func triggerFeedback(_ result: HitResult) {
        lastHitResult = result
        feedbackResetTask?.cancel()
        feedbackResetTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            if !Task.isCancelled {
                self.lastHitResult = nil
            }
        }
    }

    // MARK: - Note Position Helper

    /// Returns the x offset (from leading edge) for a note given screen geometry.
    /// - Parameters:
    ///   - note: The active note.
    ///   - screenWidth: Full screen width in points.
    /// - Returns: Offset from the left edge in points.
    func noteXPosition(for note: ActiveNote, screenWidth: CGFloat) -> CGFloat {
        let hitZoneX = screenWidth * Self.hitZoneFraction
        let speed = screenWidth / CGFloat(travelDuration)  // pt/s
        let secondsUntilHit = note.input.time - currentTime
        return hitZoneX + CGFloat(secondsUntilHit) * speed
    }
}

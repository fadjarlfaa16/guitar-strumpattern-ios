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
    static let perfect: TimeInterval = 0.08   // ±80 ms
    static let good:    TimeInterval = 0.15   // ±150 ms
}

// MARK: - ViewModel

@MainActor
class RhythmGameViewModel: ObservableObject {

    // MARK: Published State
    @Published var activeNotes:   [ActiveNote] = []
    @Published var score:         Int          = 0
    @Published var combo:         Int          = 0
    @Published var lastHitResult: HitResult?   = nil
    @Published var isPlaying:     Bool         = false
    @Published var currentTime:   TimeInterval = 0
    @Published var isFinished:    Bool         = false
    @Published var isPaused:      Bool         = false
    @Published var isTutorialPaused: Bool      = false
    @Published var isTutorialActive: Bool
    @Published var hasPassedTutorialPause: Bool = false
    @Published var currentChord:  String?      = nil

    // MARK: Configuration
    var bpm: Int
    private(set) var chordGroups: [ChordGroup]

    // MARK: Layout Constants
    /// How many seconds before its hit time a note appears at the right edge.
    let travelDuration: TimeInterval = 2.5
    /// Fraction of screen width where the hit zone line sits (from the left).
    static let hitZoneFraction: CGFloat = 0.20
    /// Visual width of one StrumBlock (icon 55pt + 16pt padding each side ≈ 87, rounded to 88).
    static let noteBlockSize: CGFloat = 88

    /// Set by the view on appear / resize. Must be > 0 before startGame().
    var screenWidth: CGFloat = 0

    /// Scrolling speed in points per second. Derived from screenWidth and travelDuration.
    var speed: CGFloat {
        guard screenWidth > 0 else { return 1 }
        return screenWidth / CGFloat(travelDuration)
    }

    // MARK: Private
    private var timer:             Timer?
    private var startDate:         Date?
    /// Elapsed time when the game was paused, used to resume seamlessly.
    private var pausedTime:        TimeInterval        = 0
    /// Groups waiting to be spawned, sorted by startTime ascending.
    private var pendingGroups:     [ChordGroup]       = []
    private var feedbackResetTask: Task<Void, Never>? = nil

    // MARK: Init

    init(chordGroups: [ChordGroup] = ChordGroup.sampleGroups, bpm: Int = 120, isTutorialActive: Bool = false) {
        self.chordGroups      = chordGroups
        self.bpm              = bpm
        self.isTutorialActive = isTutorialActive
    }

    // MARK: - Game Control

    func startGame() {
        reset()
        pendingGroups = chordGroups.sorted { $0.startTime < $1.startTime }
        startDate     = Date()
        isPlaying     = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    func stopGame() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }

    func reset() {
        stopGame()
        activeNotes   = []
        score         = 0
        combo         = 0
        lastHitResult = nil
        currentTime   = 0
        isFinished    = false
        isPaused      = false
        isTutorialPaused = false
        hasPassedTutorialPause = false
        currentChord  = nil
        pendingGroups = []
        startDate     = nil
        pausedTime    = 0
    }

    // MARK: - Pause / Resume

    func pauseGame() {
        guard isPlaying, !isPaused else { return }
        isPaused   = true
        pausedTime = currentTime
        timer?.invalidate()
        timer = nil
    }

    func resumeGame() {
        guard isPaused else { return }
        isPaused  = false
        // Recalculate startDate so currentTime picks up where it left off
        startDate = Date().addingTimeInterval(-pausedTime)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    // MARK: - Game Loop

    private func tick() {
        guard let startDate else { return }
        currentTime = Date().timeIntervalSince(startDate)

        // ── Tutorial Pause ──
        if isTutorialActive && !hasPassedTutorialPause {
            if let firstGroup = chordGroups.first, let firstNoteTime = firstGroup.notes.first?.time {
                if currentTime >= firstNoteTime {
                    currentTime = firstNoteTime // snap to exact hit line
                    isTutorialPaused = true
                    pausedTime = currentTime
                    timer?.invalidate()
                    timer = nil
                    return // pause the game visually and mechanically
                }
            }
        }

        // ── Spawn entire chord groups ──
        // All notes in a group appear together so the pill and notes arrive as a unit.
        let spawnThreshold = currentTime + travelDuration
        while let group = pendingGroups.first, group.startTime <= spawnThreshold {
            for note in group.notes {
                activeNotes.append(ActiveNote(id: note.id, input: note))
            }
            pendingGroups.removeFirst()
        }

        // ── Expire missed notes ──
        // Pure time-based: note expires when currentTime has passed its time
        // by more than the good window + a small buffer.
        for i in activeNotes.indices {
            let n = activeNotes[i]
            guard !n.isHit && !n.isExpired else { continue }
            if currentTime - n.input.time > TimingWindow.good + 0.05 {
                activeNotes[i].isExpired  = true
                activeNotes[i].hitResult  = .miss
                combo = 0
                triggerFeedback(.miss)
            }
        }

        // ── Remove notes that scrolled fully off the left side ──
        activeNotes.removeAll { n in
            n.isExpired && (currentTime - n.input.time) > travelDuration
        }

        // ── Update current chord label ──
        updateCurrentChord()

        // ── End check ──
        if pendingGroups.isEmpty && activeNotes.isEmpty {
            if let lastGroup = chordGroups.last, let lastNote = lastGroup.notes.last {
                if currentTime > lastNote.time + travelDuration {
                    stopGame()
                    isFinished = true
                }
            }
        }
    }

    // MARK: - Current Chord

    private func updateCurrentChord() {
        let lead  = 0.30    // show chord slightly before first note arrives
        let trail = TimingWindow.good + 0.15   // keep chord briefly after last note passes

        let group = chordGroups.first { g in
            currentTime >= g.startTime - lead && currentTime <= g.endTime + trail
        }
        let c = group?.chord
        if currentChord != c { currentChord = c }
    }

    // MARK: - Player Action

    /// Called when the player strums up or down.
    func onAction(direction: String) {
        guard isPlaying, !isPaused else { return }

        // Find the closest unhit note to currentTime
        let candidates = activeNotes
            .filter { !$0.isHit && !$0.isExpired }
            .sorted { abs($0.input.time - currentTime) < abs($1.input.time - currentTime) }

        guard let closest = candidates.first,
              let idx = activeNotes.firstIndex(where: { $0.id == closest.id }) else {
            combo = 0; triggerFeedback(.miss); return
        }

        // ── Tutorial Pause Logic ──
        if isTutorialPaused {
            // In tutorial pause, force the user to strum the correct direction
            guard closest.input.direction == direction else {
                triggerFeedback(.miss)
                return
            }
            
            // Correct strum! Resume the game
            isTutorialPaused = false
            hasPassedTutorialPause = true
            startDate = Date().addingTimeInterval(-pausedTime)
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in self?.tick() }
            }
        }

        let delta = abs(closest.input.time - currentTime)

        // Wrong direction is always a miss
        guard closest.input.direction == direction else {
            combo = 0; triggerFeedback(.miss); return
        }

        if delta <= TimingWindow.perfect      { register(index: idx, result: .perfect) }
        else if delta <= TimingWindow.good    { register(index: idx, result: .good)    }
        else { combo = 0; triggerFeedback(.miss) }
    }

    // MARK: - Helpers

    private func register(index: Int, result: HitResult) {
        activeNotes[index].isHit     = true
        activeNotes[index].hitResult = result
        activeNotes[index].isExpired = true
        switch result {
        case .perfect: score += 300; combo += 1
        case .good:    score += 100; combo += 1
        case .miss:    combo = 0
        }
        triggerFeedback(result)
    }

    private func triggerFeedback(_ result: HitResult) {
        lastHitResult = result
        feedbackResetTask?.cancel()
        feedbackResetTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            if !Task.isCancelled { self.lastHitResult = nil }
        }
    }

    // MARK: - Position Helpers
    //
    // All positions are derived directly from the note's BPM-based timestamp.
    // Faster BPM = notes closer together on screen.
    // Slower BPM = notes further apart on screen.

    /// X center position for a note, based purely on its stored time.
    func noteXPosition(for note: ActiveNote) -> CGFloat {
        guard screenWidth > 0 else { return 0 }
        let hitX = screenWidth * Self.hitZoneFraction
        return hitX + CGFloat(note.input.time - currentTime) * speed
    }

    /// Leading (left) edge X of a chord group's pill background.
    /// The pill starts half a block-width before the first note's center.
    func groupLeadingX(for group: ChordGroup) -> CGFloat {
        guard screenWidth > 0 else { return 0 }
        let hitX = screenWidth * Self.hitZoneFraction
        let firstNoteCX = hitX + CGFloat(group.startTime - currentTime) * speed
        return firstNoteCX - Self.noteBlockSize / 2
    }

    /// Width of a chord group's pill background.
    /// Spans from half a block before the first note to half a block after the last.
    func groupPillWidth(for group: ChordGroup) -> CGFloat {
        guard screenWidth > 0 else { return Self.noteBlockSize }
        let timeSpan = CGFloat(group.endTime - group.startTime)
        return timeSpan * speed + Self.noteBlockSize
    }
}

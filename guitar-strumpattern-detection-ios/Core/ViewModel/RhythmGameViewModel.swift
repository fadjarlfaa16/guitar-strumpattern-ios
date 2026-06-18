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
    @Published var isPlaying:     Bool         = false
    @Published var currentTime:   TimeInterval = 0
    @Published var isFinished:    Bool         = false
    @Published var isPaused:      Bool         = false
    @Published var isPausedForInput: Bool      = false
    @Published var hasPassedFirstNote: Bool    = false
    @Published var currentChord:  String?      = nil

    // MARK: Configuration
    var bpm: Int
    private(set) var chordGroups: [ChordGroup]
    private let autoPlay: Bool

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
    /// Optional audio player for timing sync
    var audioPlayer: AudioPlayerManager?
    /// Flag untuk track jika timing dari audio atau local timer
    private var useAudioTiming: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []

    init(chordGroups: [ChordGroup] = ChordGroup.sampleGroups, bpm: Int = 120, autoPlay: Bool = false) {
        self.chordGroups = chordGroups
        self.bpm         = bpm
        self.autoPlay    = autoPlay
    }

    // MARK: - Game Control

    func startGame(startPaused: Bool = false) {
        reset()
        pendingGroups = chordGroups.sorted { $0.startTime < $1.startTime }
        
        // Setup audio timing if available
        if let audioPlayer = audioPlayer {
            useAudioTiming = true
            setupAudioTimeObserver()
            if !startPaused {
                audioPlayer.play()
            }
        } else {
            // Fallback ke local timer
            useAudioTiming = false
            if !startPaused {
                startDate = Date()
                startLocalTimer()
            }
        }
        
        isPlaying = true
        if startPaused {
            isPaused = true
            tick()
        }
    }

    func stopGame() {
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        cancellables.removeAll()
        isPlaying = false
    }

    func reset() {
        stopGame()
        activeNotes   = []
        currentTime   = 0
        isFinished    = false
        isPaused      = false
        isPausedForInput = false
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
        audioPlayer?.pause()
    }

    func resumeGame() {
        guard isPaused else { return }
        isPaused  = false
        
        // If we are waiting for a user strum due to a miss, do NOT restart the timeline.
        // It will restart naturally when they strum correctly in onAction().
        if isPausedForInput { return }
        
        if useAudioTiming {
            audioPlayer?.play()
        } else {
            // Recalculate startDate so currentTime picks up where it left off
            startDate = Date().addingTimeInterval(-pausedTime)
            startLocalTimer()
        }
    }
    
    // MARK: - Private Timer Methods
    
    private func startLocalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }
    
    private func setupAudioTimeObserver() {
        guard let audioPlayer = audioPlayer else { return }
        
        // Subscribe to audio player's currentTime updates
        audioPlayer.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.currentTime = time
                self?.tick()
            }
            .store(in: &cancellables)
        
        // Monitor isPlaying
        audioPlayer.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                if !isPlaying && self?.isPlaying == true && self?.isPaused == false {
                    // Audio finished
                    self?.tick()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Game Loop

    private func tick() {
        // Saat audio timing: currentTime sudah di-set oleh Combine subscriber sebelum tick() dipanggil
        // Saat local timer: hitung dari startDate
        if !useAudioTiming {
            guard let startDate else { return }
            currentTime = Date().timeIntervalSince(startDate)
        }

        // ── Auto Pause on Miss ──
        if !autoPlay && !isPausedForInput {
            // Find the earliest unhit note
            let unhitNotes = activeNotes.filter { !$0.isHit && !$0.isExpired }
            if let earliest = unhitNotes.min(by: { $0.input.time < $1.input.time }) {
                // If it reached the hit line without being strummed
                if currentTime >= earliest.input.time {
                    currentTime = earliest.input.time // snap to exact hit line
                    isPausedForInput = true
                    pausedTime = currentTime
                    timer?.invalidate()
                    timer = nil
                    audioPlayer?.pause() // pause audio saat note terlewat
                    return // pause the game visually and mechanically
                }
            }
        }

        if autoPlay {
            for idx in activeNotes.indices {
                guard !activeNotes[idx].isExpired,
                      currentTime >= activeNotes[idx].input.time else { continue }
                activeNotes[idx].isHit = true
                activeNotes[idx].isExpired = true
                if !hasPassedFirstNote { hasPassedFirstNote = true }
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

        // Find the earliest unhit note chronologically
        let unhitNotes = activeNotes
            .filter { !$0.isHit && !$0.isExpired }
            .sorted { $0.input.time < $1.input.time }

        guard let target = unhitNotes.first,
              let idx = activeNotes.firstIndex(where: { $0.id == target.id }) else {
            return
        }

        let delta = target.input.time - currentTime

        // If the game is already paused waiting for this note
        if isPausedForInput {
            if target.input.direction == direction {
                // Correct strum! Resume the timeline.
                activeNotes[idx].isHit = true
                activeNotes[idx].isExpired = true
                if !hasPassedFirstNote { hasPassedFirstNote = true }
                
                isPausedForInput = false
                if useAudioTiming {
                    audioPlayer?.resume() // resume audio saat strum benar
                } else {
                    startDate = Date().addingTimeInterval(-pausedTime)
                    startLocalTimer()
                }
            }
            // If wrong strum while paused, do nothing (stay paused)
            return
        }

        // If the game is flowing normally:
        // Define a strict hit window (e.g., 0.2 seconds before the line)
        let hitWindow: TimeInterval = 0.20

        if delta > hitWindow {
            // Strummed too early. Ignore it to prevent early hits or sudden timeline shifts.
            return
        }

        // Inside the hit window:
        if target.input.direction == direction {
            // Correct strum!
            activeNotes[idx].isHit = true
            activeNotes[idx].isExpired = true
            if !hasPassedFirstNote { hasPassedFirstNote = true }
        } else {
            // Wrong strum inside the window!
            // We do NOTHING here. By ignoring it, the timeline continues flowing naturally
            // for the remaining fraction of a second until it hits the line, where the 
            // `tick()` auto-pause will cleanly freeze the note exactly on the hit line.
            // This completely fixes the "sudden shift" bug.
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

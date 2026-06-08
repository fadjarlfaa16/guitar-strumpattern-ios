//
//  PlayingSessionView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import SwiftUI

// MARK: - Playing Session View

struct PlayingSessionView: View {

    // MARK: - Parameters

    /// Chord segments — each segment's startTime anchors its group.
    var chords: [ChordSegment]
    /// Repeating pattern applied once per chord.
    var pattern: [StrumBeat]
    /// Beats per minute — controls spacing between notes.
    var bpm: Int
    /// Time signature, e.g. "4/4", "3/4", "6/8".
    var timeSignature: String

    /// Duration limit for repeating the sequence (e.g. "3:00"). If nil, plays once.
    var duration: String?
    
    /// If true, delays the first notes by 3 seconds and shows a tutorial prompt.
    var isFirstTime: Bool

    // MARK: - ViewModel & State

    @StateObject private var vm: RhythmGameViewModel
    @State private var screenWidth: CGFloat = 0

    // MARK: - Init

    init(
        chords:        [ChordSegment] = ChordGroup.sampleSegments,
        pattern:       [StrumBeat]    = ChordGroup.samplePattern,
        bpm:           Int            = 120,
        timeSignature: String         = ChordGroup.sampleTimeSignature,
        duration:      String?        = nil,
        isFirstTime:   Bool           = false
    ) {
        self.pattern       = pattern
        self.bpm           = bpm
        self.timeSignature = timeSignature
        self.duration      = duration
        self.isFirstTime   = isFirstTime
        
        var processedChords = chords
        if isFirstTime {
            // Give it 2.0s of clean slide-in time before it hits the line and pauses
            let delay: TimeInterval = 2.0
            processedChords = chords.map {
                ChordSegment(startTime: $0.startTime + delay, endTime: $0.endTime + delay, label: $0.label)
            }
        }
        self.chords = processedChords

        let groups = ChordGroup.build(
            chords: processedChords, pattern: pattern,
            bpm: bpm, timeSignature: timeSignature, duration: duration
        )
        _vm = StateObject(wrappedValue: RhythmGameViewModel(chordGroups: groups, bpm: bpm, isTutorialActive: isFirstTime))
    }

    // MARK: - Actions

    private func handleStrumUp()   { vm.onAction(direction: "up") }
    private func handleStrumDown() { vm.onAction(direction: "down") }

    private var hitZoneX: CGFloat { screenWidth * RhythmGameViewModel.hitZoneFraction }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                hudBar
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)

                ZStack {
                    rhythmLane
                    
                    if vm.isTutorialActive && !vm.hasPassedTutorialPause {
                        Text("STRUM BASED ON THE ARROW")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundStyle(.brandColorAccentGreen)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.85))
                                    .strokeBorder(.brandColorAccentGreen.opacity(0.8), lineWidth: 2)
                            )
                            .shadow(color: .brandColorAccentGreen.opacity(0.5), radius: 15)
                            .offset(y: -80)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }

                strumButtons
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
            }
            
            // Feedback overlay
            if let result = vm.lastHitResult {
                feedbackOverlay(result: result)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.7)),
                        removal: .opacity
                    ))
                    .animation(.spring(response: 0.18, dampingFraction: 0.55), value: vm.lastHitResult)
                    .allowsHitTesting(false)
            }

            // Finished overlay
            if vm.isFinished {
                finishedOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: vm.isFinished)
            }

            // Pause overlay
            if vm.isPaused {
                pauseOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: vm.isPaused)
            }
        }
        .onTapGesture {
            if vm.isPlaying && !vm.isPaused && !vm.isFinished {
                vm.pauseGame()
            }
        }
        .onKeyPress(.upArrow)   { handleStrumUp();   return .handled }
        .onKeyPress(.downArrow) { handleStrumDown();  return .handled }
        .onReceive(NotificationCenter.default.publisher(for: StrumNotifier.strumUpNotification)) { _ in
            handleStrumUp()
        }
        .onReceive(NotificationCenter.default.publisher(for: StrumNotifier.strumDownNotification)) { _ in
            handleStrumDown()
        }
        .onAppear { 
            lockToLandscape()
            vm.startGame() 
        }
        .onDisappear { unlockOrientation(); vm.stopGame() }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Orientation
    // ──────────────────────────────────────────────────────────────────

    private func lockToLandscape() {
        AppDelegate.orientationLock = .landscape
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    private func unlockOrientation() {
        AppDelegate.orientationLock = .portrait
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Background
    // ──────────────────────────────────────────────────────────────────

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                .backgroundPrimaryBlack,
                Color.init(hex: "282138"),
            ],
            startPoint: .bottom,
            endPoint: .top
        )
        .ignoresSafeArea()
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - HUD
    // ──────────────────────────────────────────────────────────────────

    private var hudBar: some View {
        HStack(spacing: 0) {
            // Score
            VStack(alignment: .leading, spacing: 1) {
                Text("SCORE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))
                Text("\(vm.score)")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: vm.score)
            }
            .frame(minWidth: 100, alignment: .leading)

            Spacer()

            // BPM + time signature badge
            HStack(spacing: 8) {
                Image(systemName: "metronome.fill")
                    .foregroundStyle(.brandColorAccentGreen)
                    .font(.system(size: 12))
                Text("\(bpm) BPM")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.brandColorAccentGreen)
                Text("·").foregroundStyle(.brandColorAccentGreen.opacity(0.5))
                Text(timeSignature)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.brandColorAccentGreen.opacity(0.8))
            }
            .padding(.horizontal, 14).padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.brandColorAccentGreen.opacity(0.1))
                    .strokeBorder(.brandColorAccentGreen.opacity(0.35), lineWidth: 1)
            )

            Spacer()

            // Combo
            VStack(alignment: .trailing, spacing: 1) {
                Text("COMBO")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))
                Text("×\(vm.combo)")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundStyle(vm.combo >= 5 ? .brandColorAccentGreen : .white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: vm.combo)
            }
            .frame(minWidth: 100, alignment: .trailing)
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Rhythm Lane
    // ──────────────────────────────────────────────────────────────────

    private var rhythmLane: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let blockSize = RhythmGameViewModel.noteBlockSize

            ZStack(alignment: .leading) {
                laneBackground(width: w, height: h - 100)
                hitZoneLine(height: h - 100)
                    .zIndex(100)

                // ── Chord-group pill backgrounds + floating labels ──
                ForEach(vm.chordGroups) { group in
                    let leadX = vm.groupLeadingX(for: group)
                    let pillW = vm.groupPillWidth(for: group)
                    let trailX = leadX + pillW

                    if trailX > 0 && leadX < w {
                        ChordGroupPillView(
                            group: group,
                            leadX: leadX,
                            pillW: pillW,
                            laneH: h,
                            hitZoneX: hitZoneX
                        )
                    }
                }

                // ── Individual note blocks (on top of pills) ──
                ForEach(vm.activeNotes) { note in
                    let x = vm.noteXPosition(for: note)
                    noteBlock(note: note)
                        .position(x: x, y: h / 2)
                }

                // ── Sticky chord label pinned at the timing line ──
                // Shows the current chord name fixed at the hit zone
                // while the group scrolls past.
                if let chord = vm.currentChord {
                    let labelY = h / 2 - blockSize / 2 - 14
                    Text(chord)
                        .font(AppFont.title3Bold)
                        .foregroundStyle(.brandColorAccentGreen)
                        .position(
                            x: w * RhythmGameViewModel.hitZoneFraction - 20,
                            y: labelY
                        )
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.15), value: vm.currentChord)
                }
            }
            .clipped()
            .onAppear {
                screenWidth    = w
                vm.screenWidth = w
            }
            .onChange(of: geo.size.width) { _, newW in
                screenWidth    = newW
                vm.screenWidth = newW
            }
        }
    }
    // MARK: Lane Background

    private func laneBackground(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Rectangle().fill(Color.white.opacity(0.025))
            Rectangle().fill(.textPrimaryWhite.opacity(0.3))
        }
        .frame(width: width, height: height)
    }

    // MARK: Hit Zone Line

    private func hitZoneLine(height: CGFloat) -> some View {
        ZStack {
            // Sharp line
            Rectangle()
                .fill(.textPrimaryWhite)
                .frame(width: 4, height: height)
        }
        .offset(x: hitZoneX - 1)
    }

    private var diamondAccent: some View {
        Rectangle()
            .fill(.brandColorPrimaryPurple)
            .frame(width: 9, height: 9)
            .rotationEffect(.degrees(45))
            .shadow(color: .brandColorPrimaryPurple, radius: 4)
    }

    // MARK: Note Block

    private func noteBlock(note: ActiveNote) -> some View {
        let state: NoteState = {
            if note.isHit || note.isExpired {
                return note.hitResult == .miss ? .missState : .successState
            }
            return .defaultState
        }()
        return StrumBlock(direction: note.input.direction, noteState: state)
            .opacity(note.isExpired ? 0 : 1)
            .animation(.easeOut(duration: 0.22), value: note.isExpired)
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Strum Buttons
    // ──────────────────────────────────────────────────────────────────

    private var strumButtons: some View {
        HStack(spacing: 16) {
            strumButton(
                label: "STRUM UP", icon: "arrow.up", hint: "↑ Arrow",
                colors: [Color(hue: 0.75, saturation: 0.7, brightness: 0.7),
                         .brandColorPrimaryPurple],
                glowColor: .brandColorPrimaryPurple,
                action: handleStrumUp
            )
            strumButton(
                label: "STRUM DOWN", icon: "arrow.down", hint: "↓ Arrow",
                colors: [Color(hue: 0.55, saturation: 0.7, brightness: 0.55),
                         .brandColorAccentGreen],
                glowColor: .brandColorAccentGreen,
                action: handleStrumDown
            )
        }
    }

    private func strumButton(
        label: String, icon: String, hint: String,
        colors: [Color], glowColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 18, weight: .black))
                Text(label).font(.system(size: 17, weight: .black, design: .monospaced))
                Text("· \(hint)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .opacity(0.5)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: colors,
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
            )
            .shadow(color: glowColor.opacity(0.55), radius: 14, y: 4)
        }
        .buttonStyle(StrumButtonStyle())
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Feedback Overlay
    // ──────────────────────────────────────────────────────────────────

    private func feedbackOverlay(result: HitResult) -> some View {
        VStack(spacing: 4) {
            switch result {
            case .perfect:
                Text("PERFECT")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(LinearGradient(
                        colors: [.brandColorAccentGreen, .white],
                        startPoint: .top, endPoint: .bottom))
                Text("🔥").font(.system(size: 36))
            case .good:
                Text("GOOD")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(LinearGradient(
                        colors: [.brandColorPrimaryPurple, .white],
                        startPoint: .top, endPoint: .bottom))
                Text("✨").font(.system(size: 36))
            case .miss:
                Text("MISS")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .top, endPoint: .bottom))
                Text("💀").font(.system(size: 36))
            }
        }
        .shadow(color: feedbackGlow(result), radius: 36)
    }

    private func feedbackGlow(_ r: HitResult) -> Color {
        switch r {
        case .perfect: return .brandColorAccentGreen
        case .good:    return .brandColorPrimaryPurple
        case .miss:    return .red
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Finished Overlay
    // ──────────────────────────────────────────────────────────────────

    private var finishedOverlay: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            HStack(spacing: 48) {
                VStack(spacing: 20) {
                    Text("SESSION COMPLETE")
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                    VStack(spacing: 10) {
                        statRow(label: "FINAL SCORE", value: "\(vm.score)")
                        statRow(label: "MAX COMBO",   value: "×\(vm.combo)")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1))
                    )
                }

                Button { vm.startGame() } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "play.fill").font(.system(size: 28, weight: .black))
                        Text("PLAY AGAIN").font(.system(size: 14, weight: .black, design: .monospaced))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 36).padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(
                                colors: [.brandColorPrimaryPurple,
                                         Color(hue: 0.75, saturation: 0.8, brightness: 0.6)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                    )
                    .shadow(color: .brandColorPrimaryPurple.opacity(0.55), radius: 14)
                }
                .buttonStyle(StrumButtonStyle())
            }
            .padding(40)
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
        }
        .frame(minWidth: 200)
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: - Pause Overlay
// ──────────────────────────────────────────────────────────────────

extension PlayingSessionView {
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("PAUSED")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    
                Text("TAP TO RESUME")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(.brandColorAccentGreen)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hue: 0.75, saturation: 0.4, brightness: 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.brandColorAccentGreen.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 20)
        }
        // Tapping anywhere on the pause overlay resumes the game
        .onTapGesture {
            vm.resumeGame()
        }
    }
}

// MARK: - Strum Button Style

struct StrumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.55),
                       value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview(traits: .landscapeLeft) {
    PlayingSessionView(
        chords:        ChordGroup.sampleSegments,
        pattern:       [.down, .up, .down, .noStrum, .down],
        bpm:           120,
        timeSignature: "4/4",
        duration: "3:00",
        isFirstTime: true
    )
    
}

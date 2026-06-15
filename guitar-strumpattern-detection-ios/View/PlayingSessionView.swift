//
//  PlayingSessionView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import SwiftUI

// MARK: - Playing Session View

struct PlayingSessionView: View {
    @Environment(\.dismiss) private var dismiss

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

    // MARK: - ViewModel & State

    @StateObject private var vm: RhythmGameViewModel
    @State private var screenWidth: CGFloat = 0
    @AppStorage("appState") private var navRoot: NavRoot = .onboarding
    @State private var tutorialPauseStep: Int = 0
    @Environment(AppState.self) private var appState
    @Environment(Routes.self) private var routes

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
        self._tutorialPauseStep = State(initialValue: isFirstTime ? 1 : 0)
        
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
        _vm = StateObject(wrappedValue: RhythmGameViewModel(chordGroups: groups, bpm: bpm))
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

                ZStack(alignment: .top) {
                    rhythmLane
                    
                    if appState.isFirstTime && !vm.hasPassedFirstNote {
                        Text("Let’s get started by strumming \naccording to the arrow on the screen.")
                            .font(AppFont.bodyRegular)
                            .foregroundStyle(.textPrimaryWhite)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.backgroundPrimaryBlack.opacity(0.75))
                            )
                            .offset(y: -10)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.4), value: vm.hasPassedFirstNote)
                    }
                }
                .zIndex(10)

                Spacer()
                
                HStack {
                    if(!vm.isPaused) {
                        Image.pauseFill
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.textPrimaryWhite)
                    } else {
                        Image.playFill
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.textPrimaryWhite)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(formatTime(vm.currentTime))")
                            .foregroundStyle(.white)
                        if let dur = duration {
                            Text(" / \(dur)")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 28)
                
                strumButtons
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
            }
            
            // Feedback overlay removed

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

            // Pause Tutorial Step 1
            if tutorialPauseStep == 1 {
                ZStack {
                    backgroundGradient
                    .opacity(0.6)
                    .ignoresSafeArea()
                
                    Text("Tap the screen to pause")
                        .font(AppFont.title3Bold)
                        .foregroundStyle(.textPrimaryWhite)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .transition(.opacity)
                .zIndex(20)
                .allowsHitTesting(false)
            }
        }
        .onTapGesture {
            if vm.isPlaying && !vm.isPaused && !vm.isFinished {
                vm.pauseGame()
                if tutorialPauseStep == 1 {
                    withAnimation { tutorialPauseStep = 2 }
                }
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
        .navigationBarBackButtonHidden(true)
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
                Color(hex: "170C2F")
        .ignoresSafeArea()
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - HUD
    // ──────────────────────────────────────────────────────────────────

    private var hudBar: some View {
        ZStack {
            // BPM + time signature badge
            HStack(spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "metronome.fill")
                        .foregroundStyle(.textPrimaryWhite)
                        .font(AppFont.bodyBold)
                Text("\(bpm) BPM")
                        .font(AppFont.bodyBold)
                    .foregroundStyle(.textPrimaryWhite)
                Text("·").foregroundStyle(.textPrimaryWhite.opacity(0.5))
                Text(timeSignature)
                        .font(AppFont.bodyBold)
                    .foregroundStyle(.textPrimaryWhite.opacity(0.8))
                }
                Spacer()
                if(appState.isFirstTime) {
                    Button {
                        navRoot = .uploadSong
                    } label: {
                        Text("Skip")
                            .font(AppFont.bodyBold)
                            .foregroundStyle(.textPrimaryWhite)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 5)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let maxTime = max(0, time)
        let m = Int(maxTime) / 60
        let s = Int(maxTime) % 60
        return String(format: "%d:%02d", m, s)
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
                laneBackground(width: w, height: 150)
                hitZoneLine(height: 150)
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
        Rectangle()
               .fill(Color(hex: "9E9E9E").opacity(0.06))
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
    // MARK: - Finished Overlay
    // ──────────────────────────────────────────────────────────────────

    private var finishedOverlay: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            VStack(spacing: 32) {
                Text("PATTERN COMPLETE!")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .shadow(color: .brandColorPrimaryPurple.opacity(0.6), radius: 20)

                HStack(spacing: 24) {
                    Button { 
                        // Change Pattern placeholder
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "music.note.list").font(.system(size: 24, weight: .bold))
                            Text("CHANGE PATTERN").font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 140)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.white.opacity(0.05))
                                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .buttonStyle(StrumButtonStyle())

                    Button { 
                        vm.startGame() 
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise").font(.system(size: 28, weight: .black))
                            Text("REPLAY").font(.system(size: 14, weight: .black, design: .monospaced))
                        }
                        .foregroundStyle(.white)
                        .frame(width: 160)
                        .padding(.vertical, 20)
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

                    Button {
                        if(appState.isFirstTime) {
                            navRoot = .uploadSong
                            print("isFirstTime")
                        } else {
                            routes.songLibraryRoute = NavigationPath()
                            print(navRoot.rawValue)
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.right").font(.system(size: 24, weight: .bold))
                            Text("CONTINUE").font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundStyle(.brandColorAccentGreen)
                        .frame(width: 140)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.brandColorAccentGreen.opacity(0.1))
                                .strokeBorder(.brandColorAccentGreen.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(StrumButtonStyle())
                }
            }
            .padding(40)
        }
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: - Pause Overlay
// ──────────────────────────────────────────────────────────────────

extension PlayingSessionView {
    private var pauseOverlay: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            HStack {
                Button {
                    routes.songLibraryRoute = NavigationPath()
                } label: {
                    VStack {
                        Image.arrowBackward
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(.textPrimaryWhite)
                        Text("Exit")
                            .font(.caption)
                            .foregroundStyle(.textPrimaryWhite)
                    }
                }
                Spacer()
                Button {
                    vm.startGame()
                } label: {
                    VStack {
                        Image.replay
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(.textPrimaryWhite)
                        Text("Replay")
                            .font(.caption)
                            .foregroundStyle(.textPrimaryWhite)
                    }
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    VStack {
                        Image.musicnotelist
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(.textPrimaryWhite)
                        Text("Change Pattern")
                            .font(.caption)
                            .foregroundStyle(.textPrimaryWhite)
                    }
                }
            }
            
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(Color(hue: 0.75, saturation: 0.4, brightness: 0.2))
            )
            .shadow(color: .black.opacity(0.5), radius: 20)
            
            // Pause Tutorial Step 2
            if tutorialPauseStep == 2 {
                VStack {
                    Spacer()
                    Text("Tap again to unpause")
                        .font(AppFont.title3Regular)
                        .foregroundStyle(.textPrimaryWhite)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.backgroundPrimaryBlack.opacity(0.8)))
                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        // Tapping anywhere on the pause overlay resumes the game
        .onTapGesture {
            vm.resumeGame()
            if tutorialPauseStep == 2 {
                withAnimation { tutorialPauseStep = 0 }
            }
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
        duration: "0:10",
        isFirstTime: true
    )
    .environment(AppState())
    .environment(Routes())
    
}

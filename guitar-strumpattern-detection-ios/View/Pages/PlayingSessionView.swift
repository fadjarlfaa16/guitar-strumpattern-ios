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
    /// Human-readable strumming pattern notation shown in the session HUD.
    var patternNotation: String
    /// Beats per minute — controls spacing between notes.
    var bpm: Int
    /// Time signature, e.g. "4/4", "3/4", "6/8".
    var timeSignature: String

    /// Duration limit for repeating the sequence (e.g. "3:00"). If nil, plays once.
    var duration: String?
    
    /// Audio file URL untuk playback
    var audioURL: URL?

    /// Runs the lane without requiring strum input.
    var autoPlay: Bool
    

    // MARK: - ViewModel & State

    @StateObject private var vm: RhythmGameViewModel
    @StateObject private var audioPlayer = AudioPlayerManager()
    @StateObject private var strumValidator = StrumInputValidator()
    @StateObject private var chordVM = RealTimeChordViewModel()
    @ObservedObject private var receiver = WatchReceiver.shared
    @State private var screenWidth: CGFloat = 0
    @AppStorage("isFirstLaunch") private var isFirstTime: Bool = true
    @AppStorage("navRoot") private var navRoot: NavRoot = .onboarding
    @State private var tutorialPauseStep: Int = 0
    @Environment(Routes.self) private var routes

    // MARK: - Init
    init(
        chords:        [ChordSegment] = ChordGroup.sampleSegments,
        pattern:       [StrumBeat]    = ChordGroup.samplePattern,
        bpm:           Int            = 120,
        timeSignature: String         = ChordGroup.sampleTimeSignature,
        duration:      String?        = nil,
        audioURL:      URL?           = nil,
        autoPlay:      Bool           = false,
        patternNotation: String?      = nil
    ) {
        let safeBPM = bpm > 0 ? bpm : 120
        self.pattern       = pattern
        self.patternNotation = patternNotation ?? pattern.map(\.rawValue).joined()
        self.bpm           = safeBPM
        self.timeSignature = timeSignature
        self.duration      = duration
        self.audioURL      = audioURL
        self.autoPlay      = autoPlay
        // Determine first launch status locally to avoid capturing `self` before initialization
        let defaultIsFirst = UserDefaults.standard.object(forKey: "isFirstLaunch")
        let isFirst = defaultIsFirst == nil ? true : (defaultIsFirst as? Bool ?? true)

        self._tutorialPauseStep = State(initialValue: isFirst ? 1 : 0)
        
        var processedChords = chords
        if isFirst {
            
            // Give it 2.0s of clean slide-in time before it hits the line and pauses
            let delay: TimeInterval = 2.0
            processedChords = chords.map {
                ChordSegment(startTime: $0.startTime + delay, endTime: $0.endTime + delay, label: $0.label)
            }
        }
        self.chords = processedChords

        let groups = ChordGroup.build(
            chords: processedChords, pattern: pattern,
            bpm: safeBPM, timeSignature: timeSignature, duration: duration
        )
        
        _vm = StateObject(wrappedValue: RhythmGameViewModel(chordGroups: groups, bpm: safeBPM, autoPlay: autoPlay))
    }

    // MARK: - Actions

    private func handleStrumUp()   { vm.onAction(direction: "up") }
    private func handleStrumDown() { vm.onAction(direction: "down") }

    private var usesStrumValidator: Bool { !autoPlay }

    private var hitZoneX: CGFloat { screenWidth * RhythmGameViewModel.hitZoneFraction }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                SessionHUDBar(
                    bpm: bpm,
                    timeSignature: timeSignature,
                    patternNotation: patternNotation,
                    isFirstTime: isFirstTime
                ) {
                    navRoot = .uploadSong
                }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)

                ZStack(alignment: .top) {
                    RhythmLaneView(
                        vm: vm,
                        screenWidth: $screenWidth,
                        hitZoneX: hitZoneX
                    )

                    if isFirstTime && !vm.hasPassedFirstNote {
                        Text("Let’s get started by strumming \naccording to the arrow on the screen.")
                            .font(AppFont.bodyRegular)
                            .foregroundStyle(.textPrimaryWhite)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
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
                    
                    Text("AI: \(vm.liveDetectedChord) | Strum: \(receiver.lastStrum)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.yellow)
                        .padding(.leading, 16)
                        
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(formatTime(vm.currentTime))")
                            .foregroundStyle(.white)
                        if let dur = duration {
                            Text(" / \(dur)")
                                .foregroundStyle(.white.opacity(0.5))
                        } else {
                            let maxT = vm.chordGroups.last?.endTime ?? 0
                            if maxT > 0 {
                                Text(" / \(formatTime(maxT))")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 28)
                
                if !autoPlay && !usesStrumValidator {
                    StrumButtonsView(
                        onUp: handleStrumUp,
                        onDown: handleStrumDown
                    )
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
            }
            

            if vm.isFinished {
                FinishedOverlay(
                    isFirstTime: isFirstTime,
                    onReplay: {
                        vm.startGame()
                    },
                    onContinue: {
                        if isFirstTime {
                            navRoot = .uploadSong
                        } else {
                            routes.songLibraryRoute = NavigationPath()
                        }
                    }
                )
            }

            if vm.isPaused {
                PauseOverlay(
                    tutorialPauseStep: tutorialPauseStep,
                    onExit: {
                        routes.songLibraryRoute = NavigationPath()
                    },
                    onReplay: {
                        vm.startGame()
                    },
                    onChangePattern: {
                        dismiss()
                    },
                    onResume: {
                        vm.resumeGame()
                    }
                )
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
        .onReceive(chordVM.$currentChord) { detected in
            vm.liveDetectedChord = detected
        }
        .onAppear {
            let defaultIsFirst = UserDefaults.standard.object(forKey: "isFirstLaunch")
            let isFirst = defaultIsFirst == nil ? true : (defaultIsFirst as? Bool ?? true)
            print("isFirstTime is \(isFirst)")
            
            WatchReceiver.shared.requiresSoundValidation = false
            lockToLandscape()

            if let audioURL = audioURL {
                audioPlayer.enablesMicrophoneInput = usesStrumValidator
                audioPlayer.setupPlayer(with: audioURL)
                vm.audioPlayer = audioPlayer
            }

            setupStrumValidator()
            
            if usesStrumValidator {
                if StrumCalibrationStore.isCalibrated {
                    let thresholds = StrumCalibrationStore.loadThresholds()
                    chordVM.updateSoundThresholds(baseDecibels: thresholds.base, spikeDecibels: thresholds.spike)
                }
                chordVM.startListening()
            }
            
            vm.startGame()
        }
        .onDisappear {
            unlockOrientation()
            strumValidator.stop()
            chordVM.stopListening()
            vm.stopGame()
            audioPlayer.stop()
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .navigationBarBackButtonHidden(true)
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: - Orientation
    // ──────────────────────────────────────────────────────────────────

    private func setupStrumValidator() {
        guard usesStrumValidator else { return }
        strumValidator.allowsPlayback = audioURL != nil
        strumValidator.onStrumConfirmed = { direction in
            vm.onAction(direction: direction)
        }
        strumValidator.start()
    }

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


    private func formatTime(_ time: TimeInterval) -> String {
        let maxTime = max(0, time)
        let m = Int(maxTime) / 60
        let s = Int(maxTime) % 60
        return String(format: "%d:%02d", m, s)
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
    )
    .environment(Routes())
    
}

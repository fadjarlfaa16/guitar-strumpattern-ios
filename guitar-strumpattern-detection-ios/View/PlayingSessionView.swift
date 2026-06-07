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
    /// The strum pattern — array of timestamped notes. Hardcoded by default.
    var pattern: [NoteInput] = NoteInput.samplePattern
    /// Beats per minute — for display.
    var bpm: Int = 120

    /// Called when an "up" strum is detected (button tap, key press, or future mic input).
    /// Hardcoded default: notifies the game ViewModel of an up strum.
    var onStrumUp: (() -> Void)? = nil

    /// Called when a "down" strum is detected (button tap, key press, or future mic input).
    /// Hardcoded default: notifies the game ViewModel of a down strum.
    var onStrumDown: (() -> Void)? = nil

    // MARK: - ViewModel
    @StateObject private var vm: RhythmGameViewModel

    // MARK: - Local State
    @State private var screenWidth: CGFloat = 0

    // MARK: - Init
    init(
        pattern: [NoteInput] = NoteInput.samplePattern,
        bpm: Int = 120,
        onStrumUp: (() -> Void)? = nil,
        onStrumDown: (() -> Void)? = nil
    ) {
        self.pattern = pattern
        self.bpm = bpm
        self.onStrumUp = onStrumUp
        self.onStrumDown = onStrumDown
        _vm = StateObject(wrappedValue: RhythmGameViewModel(pattern: pattern, bpm: bpm))
    }

    // MARK: - Action Handlers (hardcoded defaults call vm directly)
    private func handleStrumUp() {
        vm.onAction(direction: "up")
        onStrumUp?()
    }

    private func handleStrumDown() {
        vm.onAction(direction: "down")
        onStrumDown?()
    }

    // MARK: - Hit Zone X
    private var hitZoneX: CGFloat {
        screenWidth * RhythmGameViewModel.hitZoneFraction
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // ── Background ──
            backgroundGradient

            VStack(spacing: 0) {
                // ── HUD ──
                hudBar
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)

                // ── Rhythm Lane ──
                rhythmLane

                // ── Strum Buttons ──
                strumButtons
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
            }

            // ── Feedback Overlay ──
            if let result = vm.lastHitResult {
                feedbackOverlay(result: result)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.7)),
                        removal: .opacity
                    ))
                    .animation(.spring(response: 0.18, dampingFraction: 0.55), value: vm.lastHitResult)
                    .allowsHitTesting(false)
            }

            // ── Finished Overlay ──
            if vm.isFinished {
                finishedOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: vm.isFinished)
            }
        }
        // ── Keyboard Shortcuts (iPad physical keyboard) ──
        .onKeyPress(.upArrow)   { handleStrumUp();   return .handled }
        .onKeyPress(.downArrow) { handleStrumDown();  return .handled }
        // ── Orientation: force landscape ──
        .onAppear {
            lockToLandscape()
            vm.startGame()
        }
        .onDisappear {
            unlockOrientation()
            vm.stopGame()
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    // MARK: - Orientation Helpers
    private func lockToLandscape() {
        // 1. Tell iOS this screen only supports landscape.
        AppDelegate.orientationLock = .landscape
        // 2. Force the system to re-query supportedInterfaceOrientations immediately.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    private func unlockOrientation() {
        // Reset to portrait for all other screens.
        AppDelegate.orientationLock = .portrait
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.75, saturation: 0.65, brightness: 0.14),
                Color.black,
                Color(hue: 0.55, saturation: 0.55, brightness: 0.11),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - HUD Bar
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

            // BPM badge (centre)
            HStack(spacing: 6) {
                Image(systemName: "metronome.fill")
                    .foregroundStyle(.brandColorAccentGreen)
                    .font(.system(size: 12))
                Text("\(bpm) BPM")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.brandColorAccentGreen)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
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

    // MARK: - Rhythm Lane
    private var rhythmLane: some View {
        GeometryReader { geo in
            let width  = geo.size.width
            let height = geo.size.height

            ZStack(alignment: .leading) {
                laneBackground(width: width, height: height)
                hitZoneLine(height: height)

                // Notes
                ForEach(vm.activeNotes) { note in
                    let xPos = vm.noteXPosition(for: note, screenWidth: width)
                    noteBlock(note: note)
                        .position(x: xPos, y: height / 2)
                }
            }
            .clipped()
            .onAppear { screenWidth = width }
            .onChange(of: geo.size.width) { _, newW in screenWidth = newW }
        }
    }

    // MARK: Lane Background
    private func laneBackground(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.025))

            // Horizontal centre divider
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)

            // Left/right edge gradients for depth
            HStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.black.opacity(0.3), Color.clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 60)
                Spacer()
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.3)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 60)
            }
        }
        .overlay(
            Rectangle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .brandColorPrimaryPurple.opacity(0.5),
                            .brandColorAccentGreen.opacity(0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .frame(width: width, height: height)
    }

    // MARK: Hit Zone Line
    private func hitZoneLine(height: CGFloat) -> some View {
        ZStack {
            // Wide glow halo
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .brandColorPrimaryPurple.opacity(0.0),
                            .brandColorPrimaryPurple.opacity(0.45),
                            .brandColorPrimaryPurple.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 24, height: height)
                .blur(radius: 12)

            // Sharp line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .brandColorPrimaryPurple.opacity(0.15),
                            .brandColorPrimaryPurple,
                            .brandColorPrimaryPurple.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: height)

            // Diamond caps
            VStack {
                diamondAccent
                Spacer()
                diamondAccent
            }
            .frame(height: height)
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

    // MARK: - Strum Buttons
    private var strumButtons: some View {
        HStack(spacing: 16) {
            // ── Strum UP ──
            strumButton(
                label: "STRUM UP",
                icon: "arrow.up",
                hint: "↑ Arrow",
                colors: [Color(hue: 0.75, saturation: 0.7, brightness: 0.7), .brandColorPrimaryPurple],
                glowColor: .brandColorPrimaryPurple,
                action: handleStrumUp
            )

            // ── Strum DOWN ──
            strumButton(
                label: "STRUM DOWN",
                icon: "arrow.down",
                hint: "↓ Arrow",
                colors: [Color(hue: 0.55, saturation: 0.7, brightness: 0.55), .brandColorAccentGreen],
                glowColor: .brandColorAccentGreen,
                action: handleStrumDown
            )
        }
    }

    private func strumButton(
        label: String,
        icon: String,
        hint: String,
        colors: [Color],
        glowColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .black))
                Text(label)
                    .font(.system(size: 17, weight: .black, design: .monospaced))
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
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
            )
            .shadow(color: glowColor.opacity(0.55), radius: 14, y: 4)
        }
        .buttonStyle(StrumButtonStyle())
    }

    // MARK: - Feedback Overlay
    private func feedbackOverlay(result: HitResult) -> some View {
        VStack(spacing: 4) {
            switch result {
            case .perfect:
                Text("PERFECT")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(colors: [.brandColorAccentGreen, .white], startPoint: .top, endPoint: .bottom)
                    )
                Text("🔥")
                    .font(.system(size: 36))
            case .good:
                Text("GOOD")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(colors: [.brandColorPrimaryPurple, .white], startPoint: .top, endPoint: .bottom)
                    )
                Text("✨")
                    .font(.system(size: 36))
            case .miss:
                Text("MISS")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom)
                    )
                Text("💀")
                    .font(.system(size: 36))
            }
        }
        .shadow(color: feedbackGlowColor(result), radius: 36)
    }

    private func feedbackGlowColor(_ result: HitResult) -> Color {
        switch result {
        case .perfect: return .brandColorAccentGreen
        case .good:    return .brandColorPrimaryPurple
        case .miss:    return .red
        }
    }

    // MARK: - Finished Overlay
    private var finishedOverlay: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            HStack(spacing: 48) {
                // Results panel
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }

                // Play again button
                Button {
                    vm.startGame()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .black))
                        Text("PLAY AGAIN")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(
                                colors: [.brandColorPrimaryPurple, Color(hue: 0.75, saturation: 0.8, brightness: 0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
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

// MARK: - Strum Button Style
struct StrumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    PlayingSessionView(
        pattern: NoteInput.samplePattern,
        bpm: 120
    )
}

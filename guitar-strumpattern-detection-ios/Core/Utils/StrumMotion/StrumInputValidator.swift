//
//  StrumInputValidator.swift
//  guitar-strumpattern-detection-ios
//

import Combine
import Foundation

@MainActor
final class StrumInputValidator: ObservableObject {

    let receiver = WatchReceiver.shared
    let chordVM = RealTimeChordViewModel()

    private var cancellables = Set<AnyCancellable>()
    private var isActive = false

    var allowsPlayback = false
    var onStrumConfirmed: ((String) -> Void)?
    var onChordDetected: ((String) -> Void)?

    init() {
        receiver.$strumPulseTrigger
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleConfirmedStrum()
            }
            .store(in: &cancellables)

        chordVM.$currentChord
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chord in
                self?.onChordDetected?(chord)
            }
            .store(in: &cancellables)
    }

    func start() {
        guard !isActive else { return }
        isActive = true

        let thresholds = StrumCalibrationStore.loadThresholds()
        receiver.micBaseThreshold = thresholds.base
        receiver.micSpikeThreshold = thresholds.spike
        receiver.requiresSoundValidation = false
        receiver.switchToChordAudioMode()
        
        receiver.soundDetectedProvider = { [weak self] in
            self?.chordVM.isSoundDetected() ?? false
        }
        
        chordVM.updateSoundThresholds(baseDecibels: thresholds.base, spikeDecibels: thresholds.spike)
        chordVM.startListening()
        
        receiver.syncAppState(state: "playing")
    }

    func stop() {
        guard isActive else { return }
        isActive = false
        chordVM.stopListening()
        receiver.soundDetectedProvider = nil
        receiver.syncAppState(state: "waitingForSong")
        WatchSessionManager.shared.stopWatchFromPhone()
    }

    private func handleConfirmedStrum() {
        let direction: String?
        switch receiver.lastStrum {
        case "Down": direction = "down"
        case "Up": direction = "up"
        default: direction = nil
        }
        guard let direction else { return }
        onStrumConfirmed?(direction)
    }
}

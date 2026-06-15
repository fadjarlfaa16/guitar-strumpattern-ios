//
//  StrumInputValidator.swift
//  guitar-strumpattern-detection-ios
//

import Combine
import Foundation

@MainActor
final class StrumInputValidator: ObservableObject {

    let receiver = WatchReceiver.shared

    private var cancellables = Set<AnyCancellable>()
    private var isActive = false

    var allowsPlayback = false
    var onStrumConfirmed: ((String) -> Void)?

    init() {
        receiver.$strumPulseTrigger
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleConfirmedStrum()
            }
            .store(in: &cancellables)
    }

    func start() {
        guard !isActive else { return }
        isActive = true

        let thresholds = StrumCalibrationStore.loadThresholds()
        receiver.micBaseThreshold = thresholds.base
        receiver.micSpikeThreshold = thresholds.spike
        receiver.switchToCalibrationAudioMode(allowsPlayback: allowsPlayback)
    }

    func stop() {
        guard isActive else { return }
        isActive = false
        receiver.audioMonitor.stopMonitoring()
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

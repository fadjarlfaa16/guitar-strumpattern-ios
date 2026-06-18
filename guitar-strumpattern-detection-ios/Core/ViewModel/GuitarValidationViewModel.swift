import Combine
import Foundation

@MainActor
final class GuitarValidationViewModel: ObservableObject {

    enum Phase: Equatable {
        case calibration
        case playing
    }

    let receiver = WatchReceiver.shared
    let chordVM = RealTimeChordViewModel()

    @Published private(set) var phase: Phase = .calibration
    @Published private(set) var strumCount: Int = 0
    @Published private(set) var lastConfirmedStrum: String?

    private var cancellables = Set<AnyCancellable>()

    var isCalibrated: Bool {
        phase == .playing
    }

    init() {
        if StrumCalibrationStore.isCalibrated {
            let thresholds = StrumCalibrationStore.loadThresholds()
            receiver.micBaseThreshold = thresholds.base
            receiver.micSpikeThreshold = thresholds.spike
            phase = .playing
        }

        receiver.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        receiver.audioMonitor.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        chordVM.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        receiver.$calibrationStatusText
            .combineLatest(receiver.$isCalibrating)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status, isCalibrating in
                self?.handleCalibrationUpdate(status: status, isCalibrating: isCalibrating)
            }
            .store(in: &cancellables)

        receiver.$strumPulseTrigger
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleConfirmedStrum()
            }
            .store(in: &cancellables)

        receiver.$micBaseThreshold
            .combineLatest(receiver.$micSpikeThreshold)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] base, spike in
                self?.chordVM.updateSoundThresholds(baseDecibels: base, spikeDecibels: spike)
            }
            .store(in: &cancellables)
    }

    func startCalibration() {
        phase = .calibration
        strumCount = 0
        lastConfirmedStrum = nil
        StrumCalibrationStore.clear()
        chordVM.stopListening()
        receiver.switchToCalibrationAudioMode()
        receiver.startCalibration()
    }

    func recalibrate() {
        startCalibration()
    }

    func stop() {
        chordVM.stopListening()
        receiver.switchToChordAudioMode()
        WatchSessionManager.shared.stopWatchFromPhone()
    }

    private func handleCalibrationUpdate(status: String, isCalibrating: Bool) {
        guard !isCalibrating else { return }
        let hasCompletedStrums = receiver.recordedSamplesCount >= receiver.targetSamples
        let ready = status.contains("Ready") || status.contains("Selesai") || hasCompletedStrums
        guard ready, phase == .calibration else { return }
        enterPlayingPhase()
    }

    private func enterPlayingPhase() {
        phase = .playing
        StrumCalibrationStore.saveCalibration(
            baseDecibels: receiver.micBaseThreshold,
            spikeDecibels: receiver.micSpikeThreshold
        )
        chordVM.updateSoundThresholds(
            baseDecibels: receiver.micBaseThreshold,
            spikeDecibels: receiver.micSpikeThreshold
        )
        receiver.switchToChordAudioMode()
        receiver.soundDetectedProvider = { [weak self] in
            self?.chordVM.isSoundDetected() ?? false
        }
        chordVM.startListening()
    }

    private func handleConfirmedStrum() {
        guard phase == .playing else { return }
        strumCount += 1
        lastConfirmedStrum = receiver.lastStrum
    }
}

import Foundation
import AVFoundation
import Combine

enum AudioThresholdMapper {
    /// Konversi dB (AVAudioRecorder) ke ambang RMS untuk SoundGate.
    static func rmsFloor(fromDecibels db: Float) -> Float {
        pow(10, db / 20) * 0.012
    }

    static func rmsSpike(fromDecibels db: Float) -> Float {
        pow(10, db / 20) * 0.004
    }
}

class AudioMonitor: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    @Published var currentDecibels: Float = -160.0
    @Published var isGateOpen: Bool = false
    
    var soundThreshold: Float = -45.0
    var suddenSpikeThreshold: Float = 3.0
    
    private var previousDecibels: Float = -160.0
    private var isWarmedUp = false
    private var lastSoundDetectedTime: Date = Date.distantPast
    
    func startMonitoring(allowsPlayback: Bool = false) {
        stopMonitoring()
        isWarmedUp = false
        previousDecibels = -160.0

        let audioSession = AVAudioSession.sharedInstance()
        do {
            if allowsPlayback {
                try audioSession.setCategory(
                    .playAndRecord,
                    mode: .measurement,
                    options: [.defaultToSpeaker, .allowBluetooth]
                )
            } else {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            }
            try audioSession.setActive(true)
            
            let url = URL(fileURLWithPath: "/dev/null")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.audioRecorder?.updateMeters()
                if let power = self.audioRecorder?.averagePower(forChannel: 0) {
                    self.currentDecibels = power

                    guard self.isWarmedUp else {
                        self.previousDecibels = power
                        self.isWarmedUp = true
                        return
                    }

                    let volumeJump = power - self.previousDecibels
                    self.previousDecibels = power

                    let gateOpen = power > self.soundThreshold && volumeJump > self.suddenSpikeThreshold
                    if gateOpen {
                        self.lastSoundDetectedTime = Date()
                    }

                    let recentlyDetected = Date().timeIntervalSince(self.lastSoundDetectedTime) < 0.3
                    if self.isGateOpen != recentlyDetected {
                        DispatchQueue.main.async {
                            self.isGateOpen = recentlyDetected
                        }
                    }
                }
            }
        } catch {
            print("Gagal menyalakan mikrofon: \(error.localizedDescription)")
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        isGateOpen = false
        currentDecibels = -160.0

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
    
    func isSoundDetected() -> Bool {
        // Toleransi waktu 0.3 detik untuk mengimbangi delay Bluetooth
        return Date().timeIntervalSince(lastSoundDetectedTime) < 0.3
    }
}

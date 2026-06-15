import Foundation
import WatchConnectivity
import Combine

class WatchReceiver: NSObject, ObservableObject, WCSessionDelegate {
    
    /// Single shared instance — ensures WCSession has exactly one delegate for the app's lifetime.
    static let shared = WatchReceiver()
    
    @Published var lastStrum: String = "Diam"
    @Published var strumPulseTrigger: UUID = UUID()
    @Published var watchDidTogglePause: UUID = UUID()
    var session = WCSession.default
    
    @Published var calibrationStatusText: String = "Siap"
    @Published var isCalibrating: Bool = false
    @Published var recordedSamplesCount: Int = 0
    @Published var targetSamples: Int = 5
    @Published var currentDecibels: Float = -160.0
    @Published var micBaseThreshold: Float = -45.0 {
        didSet { audioMonitor.soundThreshold = micBaseThreshold }
    }
    @Published var micSpikeThreshold: Float = 3.0 {
        didSet { audioMonitor.suddenSpikeThreshold = micSpikeThreshold }
    }
    
    let audioMonitor = AudioMonitor()
    var soundDetectedProvider: (() -> Bool)?
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        audioMonitor.soundThreshold = micBaseThreshold
        audioMonitor.suddenSpikeThreshold = micSpikeThreshold
        audioMonitor.startMonitoring()
        audioMonitor.$currentDecibels
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentDecibels)
    }
    
    func startCalibration() {
        if session.isReachable {
            let message = ["command": "startCalibration"]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func isSoundDetected() -> Bool {
        soundDetectedProvider?() ?? audioMonitor.isSoundDetected()
    }
    
    func switchToChordAudioMode() {
        audioMonitor.stopMonitoring()
    }
    
    func switchToCalibrationAudioMode(allowsPlayback: Bool = false) {
        soundDetectedProvider = nil
        audioMonitor.startMonitoring(allowsPlayback: allowsPlayback)
    }
    func syncAppState(state: String) {
        if session.isReachable {
            session.sendMessage(["command": "syncAppState", "state": state], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func syncPlaying(title: String, currentTime: Double, maxTime: Double, isPaused: Bool) {
        if session.isReachable {
            let msg: [String: Any] = [
                "command": "syncPlaying",
                "title": title,
                "currentTime": currentTime,
                "maxTime": maxTime,
                "isPaused": isPaused
            ]
            session.sendMessage(msg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // 1. Data Strum Normal
            if let direction = message["strumDirection"] as? String {
                if direction == "Down" || direction == "Up" {
                    if self.isSoundDetected() {
                        self.lastStrum = direction
                        self.strumPulseTrigger = UUID()
                    }
                } else if direction == "Diam" {
                    self.lastStrum = direction
                }
            }
            
            // 2. Data Kalibrasi (Two-Way Handshake)
            if let command = message["command"] as? String {
                if command == "verifyCalibration" {
                    if let yAxisValue = message["yAxis"] as? Double {
                                                                     // Di dalam fungsi session(_:didReceiveMessage:)
                        if self.isSoundDetected() {
                            let reply: [String: Any] = ["command": "approveCalibration", "yAxis": yAxisValue]
                            self.session.sendMessage(reply, replyHandler: nil, errorHandler: nil)
                        }
                    }
                } else if command == "togglePauseFromWatch" {
                    self.watchDidTogglePause = UUID()
                }
            }
            
            // 3. UI Status Sinkronisasi
            if let status = message["calibrationStatus"] as? String { self.calibrationStatusText = status }
            if let isCal = message["isCalibrating"] as? Bool { self.isCalibrating = isCal }
            if let count = message["recordedSamplesCount"] as? Int { self.recordedSamplesCount = count }
            if let target = message["targetSamples"] as? Int { self.targetSamples = target }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}

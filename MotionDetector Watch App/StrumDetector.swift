//
//  StrumDetector.swift
//  ValidateStrumTechProof
//
//  Created by Arif Fathurrahman on 11/06/26.
//

import Foundation
import CoreMotion
import WatchConnectivity
import Combine
import WatchKit

enum CalibrationState {
    case idle, calibratingDown, calibratingUp
}

enum WatchAppState: Equatable {
    case disconnected
    case calibrating
    case waitingForSong
    case playing
}

class StrumDetector: NSObject, ObservableObject, WCSessionDelegate, WKExtendedRuntimeSessionDelegate {
    
    let motionManager = CMMotionManager()
    var session = WCSession.default
    
    @Published var currentYAxis: Double = 0.0
    @Published var lastStrum: String = "Diam"
    
    // UI State
    @Published var currentWatchState: WatchAppState = .disconnected {
        didSet {
            updateExtendedRuntimeSession()
        }
    }
    @Published var songTitle: String = ""
    @Published var currentTime: Double = 0.0
    @Published var maxTime: Double = 0.0
    @Published var isPlayingPaused: Bool = false
    
    @Published var calibrationState: CalibrationState = .idle
    @Published var calibrationStatusText: String = "Siap"
    @Published var recordedSamplesCount: Int = 0
    let targetSamples = 5
    private var runtimeSession: WKExtendedRuntimeSession?
    private var temporaryCalibrationSamples: [Double] = []
    
    @Published var downThreshold: Double = 0.5
    @Published var upThreshold: Double = 0.5
    let sensitivityFactor: Double = 0.65
    var isCooldown = false
    
    private var idleResetWorkItem: DispatchWorkItem?
    private let idleTimeout: TimeInterval = 0.8
    private let minFlickRotation: Double = 1.5 // Filter Giroskop
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let command = message["command"] as? String {
                if command == "startCalibration" {
                    self.startCalibrationProcess()
                }
                else if command == "wake" {
                    WKInterfaceDevice.current().play(.notification)
                }
                else if command == "approveCalibration" {
                    if let yAxisValue = message["yAxis"] as? Double {
                        self.processApprovedCalibrationSample(yAxis: yAxisValue)
                    }
                }
                else if command == "syncAppState" {
                    if let stateStr = (message["state"] as? String) ?? (message["appState"] as? String) {
                        switch stateStr {
                        case "calibrating": self.currentWatchState = .calibrating
                        case "waitingForSong": self.currentWatchState = .waitingForSong
                        case "playing": self.currentWatchState = .playing
                        case "disconnected": self.currentWatchState = .disconnected
                        default: break
                        }
                    }
                }
                else if command == "syncPlaying" {
                    self.currentWatchState = .playing
                    if let t = message["title"] as? String { self.songTitle = t }
                    if let c = message["currentTime"] as? Double { self.currentTime = c }
                    if let m = message["maxTime"] as? Double { self.maxTime = m }
                    if let p = message["isPaused"] as? Bool { self.isPlayingPaused = p }
                }
            }
        }
    }
    
    private func syncCalibrationStateToiPhone() {
        if session.isReachable {
            let isCalibrating = (calibrationState != .idle)
            let phase: String
            switch calibrationState {
            case .calibratingDown: phase = "down"
            case .calibratingUp: phase = "up"
            case .idle: phase = "idle"
            }
            let message: [String: Any] = [
                "calibrationStatus": calibrationStatusText,
                "isCalibrating": isCalibrating,
                "calibrationPhase": phase,
                "recordedSamplesCount": recordedSamplesCount,
                "targetSamples": targetSamples
            ]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func startDetecting() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let motionData = data else { return }
            self.analyzeMotion(motion: motionData)
        }
    }
    
    func stopDetecting() { motionManager.stopDeviceMotionUpdates() }
    
    func startCalibrationProcess() {
        self.temporaryCalibrationSamples.removeAll()
        self.recordedSamplesCount = 0
        self.calibrationState = .calibratingDown
        self.calibrationStatusText = "Strum Down"
        self.currentWatchState = .calibrating
        
        syncCalibrationStateToiPhone()
        WKInterfaceDevice.current().play(.start)
    }
    
    private func analyzeMotion(motion: CMDeviceMotion) {
        let yAxis = motion.userAcceleration.y
        self.currentYAxis = yAxis
        
        let rot = motion.rotationRate
        let gyroMagnitude = sqrt(rot.x * rot.x + rot.y * rot.y + rot.z * rot.z)
        
        switch calibrationState {
        case .idle:
            guard !isCooldown else { return }
            let isRealFlick = gyroMagnitude > minFlickRotation
            
            if yAxis > downThreshold && isRealFlick {
                updateStrumState(to: "Down")
                triggerCooldown()
            } else if yAxis < -upThreshold && isRealFlick {
                updateStrumState(to: "Up")
                triggerCooldown()
            }
            
        case .calibratingDown:
            guard !isCooldown else { return }
            if yAxis > 0.3 && gyroMagnitude > 1.0 {
                requestAudioVerification(yAxisValue: abs(yAxis))
                triggerCooldown(0.5)
            }
            
        case .calibratingUp:
            guard !isCooldown else { return }
            if yAxis < -0.3 && gyroMagnitude > 1.0 {
                requestAudioVerification(yAxisValue: abs(yAxis))
                triggerCooldown(0.5)
            }
        }
    }
    
    private func requestAudioVerification(yAxisValue: Double) {
        if session.isReachable {
            // Tambahkan : [String: Any] setelah nama variabel
            let msg: [String: Any] = ["command": "verifyCalibration", "yAxis": yAxisValue]
            session.sendMessage(msg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    private func processApprovedCalibrationSample(yAxis: Double) {
        guard calibrationState != .idle else { return }
        
        temporaryCalibrationSamples.append(yAxis)
        recordedSamplesCount = temporaryCalibrationSamples.count
        
        syncCalibrationStateToiPhone()
        WKInterfaceDevice.current().play(.click)
        
        if recordedSamplesCount >= targetSamples {
            if calibrationState == .calibratingDown {
                finalizeDownstrokeCalibration()
            } else if calibrationState == .calibratingUp {
                finalizeUpstrokeCalibration()
            }
        }
    }
    
    private func updateStrumState(to direction: String) {
        lastStrum = direction
        sendStrumData(direction: direction)
        
        idleResetWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.lastStrum = "Diam"
            self?.sendStrumData(direction: "Diam")
        }
        idleResetWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + idleTimeout, execute: workItem)
    }
    
    private func finalizeDownstrokeCalibration() {
        let average = temporaryCalibrationSamples.reduce(0, +) / Double(targetSamples)
        self.downThreshold = average * sensitivityFactor
        
        temporaryCalibrationSamples.removeAll()
        recordedSamplesCount = 0
        
        self.calibrationState = .calibratingUp
        
        syncCalibrationStateToiPhone()
        WKInterfaceDevice.current().play(.success)
    }
    
    private func finalizeUpstrokeCalibration() {
        let average = temporaryCalibrationSamples.reduce(0, +) / Double(targetSamples)
        self.upThreshold = average * sensitivityFactor
        self.calibrationState = .idle
        self.calibrationStatusText = "Selesai"
        
        syncCalibrationStateToiPhone()
        WKInterfaceDevice.current().play(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.currentWatchState = .waitingForSong
            self.syncCalibrationStateToiPhone()
        }
    }
    
    private func sendStrumData(direction: String) {
        if session.isReachable {
            let message = ["strumDirection": direction]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    private func triggerCooldown(_ duration: Double = 0.2) {
        isCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isCooldown = false
        }
    }
    
    func togglePauseFromWatch() {
        // Immediately toggle local state so the Watch UI responds instantly
        isPlayingPaused.toggle()
        if session.isReachable {
            session.sendMessage(["command": "togglePauseFromWatch"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    // MARK: - Extended Runtime Session Helpers
    
    private func updateExtendedRuntimeSession() {
        if currentWatchState == .calibrating || currentWatchState == .playing {
            startExtendedRuntimeSession()
        } else {
            stopExtendedRuntimeSession()
        }
    }
    
    private func startExtendedRuntimeSession() {
        guard runtimeSession == nil else { return }
        
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        self.runtimeSession = session
        session.start()
        print("WKExtendedRuntimeSession started for state: \(currentWatchState)")
    }
    
    private func stopExtendedRuntimeSession() {
        if let session = runtimeSession {
            session.invalidate()
            runtimeSession = nil
            print("WKExtendedRuntimeSession invalidated manually")
        }
    }
    
    // MARK: - WKExtendedRuntimeSessionDelegate
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.runtimeSession = nil
            print("WKExtendedRuntimeSession invalidated. Reason: \(reason), Error: \(error?.localizedDescription ?? "None")")
        }
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("WKExtendedRuntimeSession did start")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("WKExtendedRuntimeSession will expire soon")
    }
}

//
//  WatchReceiver.swift
//  guitar-strumpattern-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//

import Foundation
import WatchConnectivity
import Combine

class WatchReceiver: ObservableObject {
    
    /// Single shared instance — ensures WCSession has exactly one delegate for the app's lifetime.
    static let shared = WatchReceiver()
    
    @Published var lastStrum: String = "Diam"
    @Published var strumPulseTrigger: UUID = UUID()
    @Published var watchDidTogglePause: UUID = UUID() 
    @Published var calibrationStatusText: String = "Siap"
    @Published var isCalibrating: Bool = false
    @Published var calibrationPhase: String = "down"
    @Published var recordedSamplesCount: Int = 0
    @Published var targetSamples: Int = 5
    @Published var currentDecibels: Float = -160.0
    @Published var micBaseThreshold: Float = -45.0 {
        didSet { audioMonitor.soundThreshold = micBaseThreshold }
    }
    @Published var micSpikeThreshold: Float = 3.0 {
        didSet { audioMonitor.suddenSpikeThreshold = micSpikeThreshold }
    }
    
    @Published var requiresSoundValidation: Bool = false
    
    let audioMonitor = AudioMonitor()
    var soundDetectedProvider: (() -> Bool)?

    private let sessionManager = WatchSessionManager.shared
    private var messageHandlerID: UUID?
     
    init() {
            // lebih aman jika kita pastikan pemanggilan sessionManager ada di Main Thread
            Task { @MainActor in
                sessionManager.activate()
                messageHandlerID = sessionManager.registerMessageHandler { [weak self] message in
                    self?.handleMessage(message)
                }
            }
            audioMonitor.soundThreshold = micBaseThreshold
            audioMonitor.suddenSpikeThreshold = micSpikeThreshold
            audioMonitor.$currentDecibels
                .receive(on: DispatchQueue.main)
                .assign(to: &$currentDecibels)
        }

    deinit {
        if let id = messageHandlerID {
            // Tangkap referensi sessionManager ke variabel lokal
            // agar bisa digunakan di dalam Task tanpa memanggil 'self'
            let manager = WatchSessionManager.shared
            Task { @MainActor in
                manager.unregisterMessageHandler(id)
            }
        }
    }
    
    func startCalibration() {
        calibrationPhase = "down"
        recordedSamplesCount = 0
        isCalibrating = true
        if sessionManager.session.isReachable {
            let message = ["command": "startCalibration"]
            sessionManager.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func syncAppState(state: String) {
        if sessionManager.session.isReachable {
            let message = ["command": "syncAppState", "appState": state]
            sessionManager.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func syncPlaying(title: String, currentTime: Double, maxTime: Double, isPaused: Bool) {
        if sessionManager.session.isReachable {
            let message: [String: Any] = [
                "command": "syncPlaying",
                "title": title,
                "currentTime": currentTime,
                "maxTime": maxTime,
                "isPaused": isPaused
            ]
            sessionManager.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
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

    private func handleMessage(_ message: [String: Any]) {
        if let direction = message["strumDirection"] as? String {
            if direction == "Down" || direction == "Up" {
                let isValid = requiresSoundValidation ? self.isSoundDetected() : true
                if isValid {
                    self.lastStrum = direction
                    self.strumPulseTrigger = UUID()
                }
            } else if direction == "Diam" {
                self.lastStrum = direction
            }
        }

        if let command = message["command"] as? String {
            if command == "verifyCalibration" {
                if let yAxisValue = message["yAxis"] as? Double {
                    let isValid = requiresSoundValidation ? self.isSoundDetected() : true
                    if isValid {
                        let reply: [String: Any] = ["command": "approveCalibration", "yAxis": yAxisValue]
                        self.sessionManager.session.sendMessage(reply, replyHandler: nil, errorHandler: nil)
                    }
                }
            } else if command == "togglePauseFromWatch" {
                self.watchDidTogglePause = UUID()
            }
        }

        if let status = message["calibrationStatus"] as? String { self.calibrationStatusText = status }
        if let isCal = message["isCalibrating"] as? Bool { self.isCalibrating = isCal }
        if let phase = message["calibrationPhase"] as? String { self.calibrationPhase = phase }
        if let count = message["recordedSamplesCount"] as? Int { self.recordedSamplesCount = count }
        if let target = message["targetSamples"] as? Int { self.targetSamples = target }
    }
}

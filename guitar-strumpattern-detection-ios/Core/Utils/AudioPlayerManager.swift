//
//  AudioPlayerManager.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 10/06/26.
//

import AVFoundation
import Foundation
import Combine

/// Manages audio playback and provides timing sync for the game
@MainActor
final class AudioPlayerManager: NSObject, ObservableObject {
    
    @Published var currentTime: TimeInterval = 0
    @Published var isPlaying: Bool = false
    @Published var playerError: String? = nil
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var displayLink: CADisplayLink?
    
    private let updateInterval: TimeInterval = 0.016  // ~60 FPS
    /// When true, audio session allows simultaneous mic input for strum validation.
    var enablesMicrophoneInput: Bool = false
    
    override init() {
        super.init()
        // Jangan aktivasi audio session di sini — hanya saat play() dipanggil
    }
    
    deinit {
        // Cleanup dipanggil secara eksplisit via stop() di onDisappear
        // Tidak bisa panggil @MainActor method dari deinit
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if enablesMicrophoneInput {
                try audioSession.setCategory(
                    .playAndRecord,
                    mode: .measurement,
                    options: [.defaultToSpeaker, .allowBluetooth]
                )
            } else {
                try audioSession.setCategory(.playback, mode: .default, options: [])
            }
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            playerError = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Public Methods
    
    /// Initialize player dengan audio file URL
    func setupPlayer(with audioURL: URL) {
        let asset = AVURLAsset(url: audioURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        if player == nil {
            player = AVPlayer()
            startTimeObserver()
        }
        
        player?.replaceCurrentItem(with: playerItem)
        playerError = nil
    }
    
    /// Start playback from beginning or resume
    func play() {
        guard let player = player else {
            playerError = "Player not initialized"
            return
        }
        
        guard player.currentItem != nil else {
            playerError = "No audio loaded"
            return
        }
        
        // Aktifkan audio session hanya saat diperlukan
        setupAudioSession()
        if timeObserver == nil {
            startTimeObserver()
        }
        player.play()
        isPlaying = true
    }
    
    /// Pause playback
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    /// Resume playback from pause
    func resume() {
        play()
    }
    
    /// Stop playback dan reset to beginning
    func stop() {
        // PENTING: harus remove time observer sebelum stop
        // agar tidak crash saat AVPlayer di-deallocate
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
    }
    
    /// Seek ke specific time
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// Get total duration
    func getDuration() -> TimeInterval {
        guard let player = player,
              let duration = player.currentItem?.duration else {
            return 0
        }
        return duration.seconds
    }
    
    // MARK: - Private Methods
    
    private func startTimeObserver() {
        guard let player = player else { return }
        
        // Remove existing observer
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        
        // Add new observer yang update current time
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: updateInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            DispatchQueue.main.async {
                self?.currentTime = time.seconds
                
                // Check if playback finished
                if let currentPlayer = self?.player,
                   let duration = currentPlayer.currentItem?.duration,
                   abs(time.seconds - duration.seconds) < 0.1 {
                    self?.isPlaying = false
                }
            }
        }
    }
    
    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        displayLink?.invalidate()
        player?.pause()
        player = nil
    }
}

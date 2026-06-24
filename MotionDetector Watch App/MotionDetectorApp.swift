//
//  MotionDetectorApp.swift
//  MotionDetector Watch App
//
//  Created by Arif Fathurrahman on 12/06/26.
//

import SwiftUI
import WatchKit
import HealthKit

// 🛠️ The Interceptor: Catches the wake-up command from the iPhone
class WatchAppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        // When iPhone triggers 'startWatchApp', this method catches it instantly
        StrumDetector.shared.startWorkoutSession(with: workoutConfiguration)
    }
}

@main
struct MotionDetector_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView(detector: StrumDetector.shared)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                let state = StrumDetector.shared.currentWatchState
                if state != .calibrating && state != .playing {
                    StrumDetector.shared.stopWorkoutSession()
                    StrumDetector.shared.currentWatchState = .disconnected
                }
            }
        }
    }
}

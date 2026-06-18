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
    var detector: StrumDetector?
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        // When iPhone triggers 'startWatchApp', this method catches it instantly
        detector?.startWorkoutSession(with: workoutConfiguration)
    }
}

@main
struct MotionDetector_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) var appDelegate
    @StateObject private var detector = StrumDetector()
    
    var body: some Scene {
        WindowGroup {
            ContentView(detector: detector)
                .onAppear {
                    // Link the app delegate to our single source of truth detector
                    appDelegate.detector = detector
                }
        }
    }
}

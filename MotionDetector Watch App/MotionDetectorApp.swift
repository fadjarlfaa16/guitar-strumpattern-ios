//
//  MotionDetectorApp.swift
//  MotionDetector Watch App
//
//  Created by Arif Fathurrahman on 12/06/26.
//

import SwiftUI
import WatchKit
import HealthKit

class WatchAppDelegate: NSObject, WKApplicationDelegate {
    var detector: StrumDetector?
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
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
                    appDelegate.detector = detector
                }
        }
    }
}

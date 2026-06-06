//
//  guitar_strumpattern_detection_iosApp.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import SwiftUI

@main
struct guitar_strumpattern_detection_iosApp: App {
    // Wire up AppDelegate so orientation locking works per-screen.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

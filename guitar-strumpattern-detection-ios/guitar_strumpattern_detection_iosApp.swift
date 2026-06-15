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
    @State private var savedSong = SavedSong()
    @State private var appState = AppState()
    @State private var router = Routes()

    init() {
        // Activate WCSession as early as possible so the Watch connection is ready.
        _ = WatchReceiver.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(savedSong)
                .environment(appState)
                .environment(router)
        }
    }
}

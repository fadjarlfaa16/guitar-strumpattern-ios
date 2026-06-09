//
//  ContentView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

enum NavRoot: String {
    case onboarding
    case songList
    case uploadSong
}

struct ContentView: View {
    @AppStorage("appState") private var appState: NavRoot = .onboarding

    var body: some View {
        switch appState {
        case .onboarding:
            OnboardingWelcome()
        case .songList:
            NavigationStack {
                SongListView()
            }
        case .uploadSong:
            NavigationStack {
                GreatPageView()
            }
        }
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

enum AppState: String {
    case onboarding
    case songList
    case uploadSong
}

struct ContentView: View {
    @AppStorage("appState") private var appState: AppState = .onboarding

    var body: some View {
        switch appState {
        case .onboarding:
            OnboardingWelcome()
        case .songList:
            SongListView(items: SongListItem.samples)
        case .uploadSong:
            GreatPageView()
        }
    }
}

#Preview {
    ContentView()
}

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

    @AppStorage("appState") private var appState: AppState = .onboarding
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true


    var body: some View {
        @Bindable var routes = routes
        
        switch appState {
        case .onboarding:
            NavigationStack {
                PrepareYourGuitarView()
            }
        case .songList:
            NavigationStack(path: $routes.songLibraryRoute) {
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

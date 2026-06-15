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
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("navRoot") private var appState: NavRoot = .onboarding
    @Environment(Routes.self) private var routes

    var body: some View {
        @Bindable var routes = routes
        
        Group {
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
        .onChange(of: appState) { _, newState in
            broadcastWatchState(newState)
        }
        .onAppear {
            broadcastWatchState(appState)
        }
    }

    private func broadcastWatchState(_ state: NavRoot) {
        WatchReceiver.shared.syncAppState(state: "waitingForSong")
    }
}

#Preview {
    ContentView()
}

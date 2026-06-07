//
//  ContentView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 05/06/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PlayingSessionView(
            pattern: NoteInput.samplePattern,
            bpm: 120
        )
        
    }
}

#Preview {
    ContentView()
}

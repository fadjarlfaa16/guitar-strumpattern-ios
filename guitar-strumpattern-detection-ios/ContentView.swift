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
            chords:        ChordGroup.sampleSegments,
            pattern:       ChordGroup.samplePattern,
            bpm:           120,
            timeSignature: "4/4",
            duration:      "3:00",
            isFirstTime:   true
        )
        
    }
}

#Preview {
    ContentView()
}

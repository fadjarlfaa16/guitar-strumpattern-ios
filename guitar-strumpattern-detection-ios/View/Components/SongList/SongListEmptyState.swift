//
//  SongListEmptyState.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

struct SongListEmptyState: View {
    var body: some View {
        VStack {
            Image.musicnotelist
                .scaledToFit()
                .frame(width: 80, height: 80)

            VStack {
                Text("Your library is empty")
                Text("Press + to add a song...")
            }
        }
    }
}

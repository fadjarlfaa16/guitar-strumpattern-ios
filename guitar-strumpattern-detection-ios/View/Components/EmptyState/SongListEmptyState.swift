//
//  SongListEmptyState.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 14/06/26.
//


//
//  SongListEmptyState.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct SongListEmptyState: View {
    var body: some View {
        VStack {
            Image.musicnotelist
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.textSecondary)

            VStack {
                Text("Your library is empty")
                    .font(AppFont.title3Bold)
                    .foregroundColor(.textSecondary)
                    .padding(.top, Spacing.xs)

                Text("Press + to add a song, then swipe left to analyze")
                    .font(AppFont.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .padding(.horizontal, Spacing.xl)
    }
}
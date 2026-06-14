//
//  SongListFirstTimeView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct SongListFirstTimeView: View {
    var onDoTutorial: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image.musicnotelist
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.textSecondary)

            Text("Finish your tutorial first")
                .font(AppFont.bodyRegular)
                .foregroundColor(.textSecondary)
                .padding(.top, Spacing.xs)

            CustomButton(title: "Do Tutorial") {
                onDoTutorial()
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.sm)
        }
        .padding(.horizontal, Spacing.xl)
    }
}
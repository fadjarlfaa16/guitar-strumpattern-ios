//
//  SongListFirstTimeState.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct SongListFirstTimeState: View {
    let onTutorialTap: () -> Void

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
                onTutorialTap()
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.sm)
        }
        .padding(.horizontal, Spacing.xl)
    }
}
#Preview {
    SongListFirstTimeState {
        print("Tutorial tapped")
    }
    .background(Color.backgroundPrimaryBlack)
}

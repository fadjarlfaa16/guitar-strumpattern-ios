//
//  SongListHeader.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct SongListHeader: View {
    var onCalibrateTapped: () -> Void

    var body: some View {
        HStack {
            Text("Song Library")
                .font(.largeTitle)
                .foregroundColor(.textPrimaryWhite)
                .bold()

            Spacer()

            Button {
                onCalibrateTapped()
            } label: {
                Label("Kalibrasi", systemImage: "applewatch")
                    .font(AppFont.bodyRegular)
                    .foregroundStyle(.textPrimaryWhite)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
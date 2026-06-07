//
//  PlayButton.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//

import SwiftUI

struct PlayButton: View {
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.brandColorPrimaryPurple)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlayButton()
}

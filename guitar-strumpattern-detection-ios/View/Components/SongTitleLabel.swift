//
//  SongTitleLabel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//

import SwiftUI

// MARK: - Song Title Label
struct SongTitleLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppFont.bodyRegular.weight(.semibold))
            .foregroundColor(.brandColorAccentGreen)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

#Preview {
    SongTitleLabel(title: "Sunny - Yorushika")
}

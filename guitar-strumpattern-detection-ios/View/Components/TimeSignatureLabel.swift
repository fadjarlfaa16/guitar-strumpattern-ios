//
//  TimeSignatureLabel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//

import SwiftUI

// MARK: - Time Signature Label
struct TimeSignatureLabel: View {
    let signature: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "music.note")
                .font(.system(size: 12))
                .foregroundColor(.accentYellow)
            Text("= \(signature)")
                .font(AppFont.bodyRegular)
                .foregroundColor(.accentYellow)
        }
    }
}

#Preview {
  TimeSignatureLabel(signature: "4/4")
}

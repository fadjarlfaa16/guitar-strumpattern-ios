//
//  BPMLabel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 06/06/26.
//

import SwiftUI

// MARK: - BPM Label
struct BPMLabel: View {
    let bpm: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "timer")
                .font(.system(size: 12))
                .foregroundColor(.brandColorAccentGreen)
            Text("= \(bpm) bpm")
<<<<<<< HEAD
                .font(AppFont.BodyRegular)
                .foregroundColor(.brandColorAccentGreen)
=======
                .font(AppFont.bodyRegular)
                .foregroundColor(.accentYellow)
>>>>>>> Feature/Onboard
        }
    }
}

#Preview {
    BPMLabel(bpm: 120)
}

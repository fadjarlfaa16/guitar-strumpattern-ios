//
//  HeroHeaderView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//

// HeroHeaderView.swift
// Komponen header atas dengan blob hijau dan teks judul

import SwiftUI

// MARK: - Hero Header View
struct HeroHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(AppFont.largeTitleBold)
                .foregroundColor(.textPrimaryWhite)
                .lineSpacing(2)

            Text(subtitle)
                .font(AppFont.bodyRegular)
                .foregroundColor(.textPrimaryWhite.opacity(0.7))
        }
    }
}

// MARK: - Preview
#Preview {
    HeroHeader(title: "Halo", subtitle: "Halo")
        .background(Color.backgroundPrimaryBlack)
}

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
struct HeroHeader<Content: View>: View {

    private let content: Content

    init(
        title: String,
        subtitle: String
    ) where Content == VStack<TupleView<(Text, Text)>> {

        self.content = VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(AppFont.largeTitleBold)
                .foregroundColor(.textPrimaryWhite)

            Text(subtitle)
                .font(AppFont.bodyRegular)
                .foregroundColor(.textPrimaryWhite.opacity(0.7))
        }
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            content
        }
    }
}

// MARK: - Preview
#Preview {
    HeroHeader(title: "Halo", subtitle: "Halo")
        .background(Color.backgroundPrimaryBlack)
}

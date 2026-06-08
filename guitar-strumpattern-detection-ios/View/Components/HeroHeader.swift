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
    var body: some View {
        ZStack(alignment: .topLeading) {
            BlobShape()
                .fill(Color.brandColorAccentGreen.opacity(0.55))
                .frame(width: 260, height: 260)
                .offset(x: -20, y: -30)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("First, Choose Your\nPreffered\nStrumming Pattern")
                    .font(AppFont.largeTitleBold)
                    .foregroundColor(.textPrimaryWhite)
                    .lineSpacing(2)

                Text("These patterns are choosed\nbased on the song's BPM and\nrhythm")
                    .font(AppFont.BodyRegular)
                    .foregroundColor(.textPrimaryWhite.opacity(0.7))
            }
            .padding(.top, Spacing.xl)
            .padding(.horizontal, Spacing.lg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 260)
        .clipped()
    }
}

// MARK: - Blob Shape
/// Shape blob organik menyerupai UI di screenshot
struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w * 0.65, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.35),
            control: CGPoint(x: w * 1.05, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.85),
            control: CGPoint(x: w * 1.0, y: h * 0.75)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.7),
            control: CGPoint(x: w * 0.2, y: h * 1.05)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview {
    HeroHeader()
        .background(Color.backgroundPrimaryBlack)
}

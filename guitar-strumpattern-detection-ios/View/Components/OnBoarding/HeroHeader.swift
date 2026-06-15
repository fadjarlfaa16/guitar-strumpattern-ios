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
    HeroHeader(title: "Halo", subtitle: "Halo")
        .background(Color.backgroundPrimaryBlack)
}

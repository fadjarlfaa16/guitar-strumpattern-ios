//
//  GreatHeaderView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//


// GreatHeaderView.swift
// Komponen header: blob hijau outline + teks "Great!" + subtitle

import SwiftUI

// MARK: - Great Header View
struct GreatHeader: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Blob outline dekoratif
            //            GreatBlobShape()
            //                .stroke(Color.brandColorAccentGreen, lineWidth: 2.5)
            //                .frame(width: 280, height: 220)
            //                .offset(x: 30, y: -20)
            
            // Teks
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Great!")
                    .font(AppFont.largeTitleBold)
                    .foregroundColor(.textPrimaryWhite)
                
                Text("Before you go, you need to add song from your local library. Make sure its in MP3, WAV, and M4A")
                    .font(AppFont.title3Regular)
                    .foregroundColor(.textPrimaryWhite)
            }
            .padding(.top, Spacing.md)
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Blob Shape (outline dekoratif kanan atas)
//struct GreatBlobShape: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let w = rect.width
//        let h = rect.height
//
//        path.move(to: CGPoint(x: w * 0.3, y: 0))
//        path.addQuadCurve(
//            to: CGPoint(x: w, y: h * 0.3),
//            control: CGPoint(x: w * 1.1, y: -h * 0.1)
//        )
//        path.addQuadCurve(
//            to: CGPoint(x: w * 0.6, y: h),
//            control: CGPoint(x: w * 1.05, y: h * 0.85)
//        )
//        path.addQuadCurve(
//            to: CGPoint(x: 0, y: h * 0.6),
//            control: CGPoint(x: w * 0.15, y: h * 1.1)
//        )
//        return path
//    }
//}

// MARK: - Preview
#Preview {
    GreatHeader()
        .background(Color.backgroundPrimaryBlack)
}

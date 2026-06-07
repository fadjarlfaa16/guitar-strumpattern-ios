//
//  GreatBottomBlobView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//


// GreatBottomBlobView.swift
// Komponen blob ungu dekoratif di pojok kanan bawah

import SwiftUI

// MARK: - Great Bottom Blob View
struct GreatBottomBlob: View {
    var body: some View {
        GreatBottomBlobShape()
            .stroke(Color.brandColorPrimaryPurple, lineWidth: 2.5)
            .frame(width: 260, height: 160)
    }
}

// MARK: - Bottom Blob Shape
struct GreatBottomBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0, y: h * 0.4))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control: CGPoint(x: w * 0.1, y: -h * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control: CGPoint(x: w * 1.05, y: h * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.4, y: h),
            control: CGPoint(x: w * 1.0, y: h * 1.1)
        )
        return path
    }
}

// MARK: - Preview
#Preview {
    GreatBottomBlob()
        .padding()
        .background(Color.backgroundPrimaryBlack)
}

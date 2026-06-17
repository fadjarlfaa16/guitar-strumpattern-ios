//
//  BlobShape.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

// MARK: - Blob Shape
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

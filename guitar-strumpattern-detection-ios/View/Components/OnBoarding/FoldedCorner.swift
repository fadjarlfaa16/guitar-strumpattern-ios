//
//  FoldedCorner.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//

import SwiftUI

// MARK: - Folded Corner Shape
/// Sudut kanan atas terpotong diagonal, efek kertas terlipat
struct FoldedCorner: Shape {
    var cornerSize: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = cornerSize

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: c))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))            
        path.closeSubpath()

        return path
    }
}

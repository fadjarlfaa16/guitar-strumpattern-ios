//
//  PrepareGuitarBackgroundLines.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 10/06/26.
//
import SwiftUI


// MARK: - Decorative Background Lines
struct PrepareGuitarBackgroundLines: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Top Green Line (Valley on left, peak on right)
                Path { path in
                    path.move(to: CGPoint(x: -20, y: height * 0.18))
                    path.addCurve(
                        to: CGPoint(x: width * 0.92, y: -30),
                        control1: CGPoint(x: width * 0.55, y: height * 0.28),
                        control2: CGPoint(x: width * 0.65, y: height * 0.25)
                    )
                }
                .stroke(
                    Color.brandColorAccentGreen.opacity(0.35),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
                
                // Bottom Purple Line (U-shape dipping below screen, exiting right)
                Path { path in
                    path.move(to: CGPoint(x: -20, y: height * 0.80))
                    path.addCurve(
                        to: CGPoint(x: width + 20, y: height * 0.70),
                        control1: CGPoint(x: width * 0.65, y: height * 1.35),
                        control2: CGPoint(x: width * 0.65, y: height * 0.85)
                    )
                }
                .stroke(
                    Color.brandColorSecondaryPink.opacity(0.35),
                    style: StrokeStyle(lineWidth: 10
                                       , lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}
#Preview {
    PrepareGuitarBackgroundLines()
}

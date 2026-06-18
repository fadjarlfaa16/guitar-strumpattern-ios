//
//  ChoosePatternBackground.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


import SwiftUI

struct ChoosePatternBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                Circle()
                    .fill(Color.brandColorAccentGreen.opacity(0.25))
                    .frame(
                        width: width * 1.3,
                        height: width * 0.9
                    )
                    .position(
                        x: width * 0.1,
                        y: height * 0
                    )

                Path { path in
                    path.move(
                        to: CGPoint(
                            x: width * 0.18,
                            y: height + 20
                        )
                    )

                    path.addCurve(
                        to: CGPoint(
                            x: width + 20,
                            y: height * 0.81
                        ),
                        control1: CGPoint(
                            x: width * 0.18,
                            y: height * 0.87
                        ),
                        control2: CGPoint(
                            x: width * 0.60,
                            y: height * 0.94
                        )
                    )
                }
                .stroke(
                    Color.brandColorSecondaryPink.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 7,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ChoosePatternBackground()
}

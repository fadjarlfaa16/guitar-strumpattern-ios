//
//  BackgroundLineStyle.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


import SwiftUI

// MARK: - Background Line Style

enum BackgroundLineStyle {
    case welcome
    case prepareGuitar
}

// MARK: - Background Lines

struct BackgroundLines: View {
    let style: BackgroundLineStyle

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                switch style {
                case .welcome:
                    welcomeLines(width: width, height: height)

                case .prepareGuitar:
                    prepareGuitarLines(width: width, height: height)
                }
            }
        }
    }
}

// MARK: - Line Variants

private extension BackgroundLines {

    @ViewBuilder
    func welcomeLines(width: CGFloat, height: CGFloat) -> some View {

        Path { path in
            path.move(to: CGPoint(x: -0.5, y: height * 0.22))
            path.addCurve(
                to: CGPoint(x: width + 20, y: height * 0.12),
                control1: CGPoint(x: width * 0.35, y: height * 0.40),
                control2: CGPoint(x: width * 0.45, y: height * -0.1)
            )
        }
        .stroke(
            Color.brandColorAccentGreen.opacity(0.2),
            style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
        )

        Path { path in
            path.move(to: CGPoint(x: -1, y: height * 0.72))
            path.addCurve(
                to: CGPoint(x: width * 0.74, y: height - 80),
                control1: CGPoint(x: width * 0.40, y: height * 0.80),
                control2: CGPoint(x: width * 0.75, y: height * 0.72)
            )
        }
        .stroke(
            Color.brandColorSecondaryPink.opacity(0.2),
            style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
        )
    }

    @ViewBuilder
    func prepareGuitarLines(width: CGFloat, height: CGFloat) -> some View {

        Path { path in
            path.move(to: CGPoint(x: -20, y: height * 0.18))
            path.addCurve(
                to: CGPoint(x: width * 0.92, y: -30),
                control1: CGPoint(x: width * 0.55, y: height * 0.28),
                control2: CGPoint(x: width * 0.65, y: height * 0.25)
            )
        }
        .stroke(
            Color.brandColorAccentGreen.opacity(0.2),
            style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
        )

        Path { path in
            path.move(to: CGPoint(x: -20, y: height * 0.80))
            path.addCurve(
                to: CGPoint(x: width + 20, y: height * 0.70),
                control1: CGPoint(x: width * 0.65, y: height * 1.35),
                control2: CGPoint(x: width * 0.65, y: height * 0.85)
            )
        }
        .stroke(
            Color.brandColorSecondaryPink.opacity(0.2),
            style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
        )
    }
}
//
//  StrumButtonsView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//
import SwiftUI
import Combine


struct StrumButtonsView: View {

    let onUp: () -> Void
    let onDown: () -> Void

    var body: some View {
        HStack(spacing: 16) {

            strumButton(
                label: "STRUM UP",
                icon: "arrow.up",
                hint: "↑ Arrow",
                colors: [
                    Color(hue: 0.75, saturation: 0.7, brightness: 0.7),
                    .brandColorPrimaryPurple
                ],
                glowColor: .brandColorPrimaryPurple,
                action: onUp
            )

            strumButton(
                label: "STRUM DOWN",
                icon: "arrow.down",
                hint: "↓ Arrow",
                colors: [
                    Color(hue: 0.55, saturation: 0.7, brightness: 0.55),
                    .brandColorAccentGreen
                ],
                glowColor: .brandColorAccentGreen,
                action: onDown
            )
        }
    }
}

private func strumButton(
    label: String, icon: String, hint: String,
    colors: [Color], glowColor: Color,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 18, weight: .black))
            Text(label).font(.system(size: 17, weight: .black, design: .monospaced))
            Text("· \(hint)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .opacity(0.5)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: colors,
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
        )
        .shadow(color: glowColor.opacity(0.55), radius: 14, y: 4)
    }
    .buttonStyle(StrumButtonStyle())
}



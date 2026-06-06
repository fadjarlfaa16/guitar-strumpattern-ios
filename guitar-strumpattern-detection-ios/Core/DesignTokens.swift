// DesignTokens.swift
// ⚠️ Placeholder — ganti isi ini dengan tokens kamu sendiri

import SwiftUI
import Foundation
// MARK: - Color Tokens
extension Color {
    // Background
    static let bgPrimary     = Color(hex: "#0D0D14")   // background utama gelap
    static let bgCard        = Color(hex: "#1A1A2E")   // background card / button

    // Accent
    static let accentGreen   = Color(hex: "#7DB83A")   // hijau olive (judul, icon)
    static let accentPurple  = Color(hex: "#4B2E7A")   // ungu gelap (button pattern)
    static let accentYellow  = Color(hex: "#D4B84A")   // kuning BPM label

    // Text
    static let textPrimary   = Color.white
    static let textSecondary = Color(hex: "#AAAAAA")
    static let textLabel     = Color(hex: "#D4B84A")   // label bpm/time
}

// MARK: - Spacing Tokens (ganti sesuai token system kamu)
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Radius Tokens
enum Radius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Typography Tokens (ganti font sesuai brand kamu)
enum AppFont {
    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    static func label(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
}

// MARK: - Hex Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

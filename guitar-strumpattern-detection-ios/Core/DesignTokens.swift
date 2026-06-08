// DesignTokens.swift
// ⚠️ Placeholder — ganti isi ini dengan tokens kamu sendiri


import SwiftUI
import Foundation

// MARK: - Color Palette
extension Color {
    // Background
    static let bgPrimary     = Color.backgroundPrimaryBlack   // background utama gelap
    static let bgCard        = Color(hex: "#1A1A2E")   // background card / button

    // Accent
    static let accentGreen   = Color.brandColorAccentGreen   // hijau olive (judul, icon)
    static let accentPurple  = Color.brandColorPrimaryPurple   // ungu gelap (button pattern)
    static let accentYellow  = Color(hex: "#D4B84A")   // kuning BPM label

    // Text
    static let textPrimary   = Color.textPrimaryWhite
    static let textSecondary = Color(hex: "#AAAAAA")
    static let textLabel     = Color(hex: "#D4B84A")   // label bpm/time
}
// MARK: - Radius Tokens
enum Radius {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
    static let full: CGFloat = 999

    static let nonclickable:   CGFloat = 8
    static let clickable: CGFloat = 999
}
// MARK: - Spacings
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Typography Tokens (ganti font sesuai brand kamu)
enum AppFont {
    static let largeTitleBold: Font = .system(size: 34, weight: .bold)
    static let largeTitleRegular: Font = .system(size: 34, weight: .regular)
    static let title2Regular : Font = .system(size: 22, weight: .regular)
    static let title3Regular : Font = .system(size: 20, weight: .regular)
    static let headlineSemibold : Font = .system(size: 20, weight: .semibold)
    static let bodyRegular : Font = .system(size: 17, weight: .regular)
    static let bodyBold : Font = .system(size: 17, weight: .bold)
    static let caption1Regular : Font = .system(size: 12, weight: .regular)
    static let caption2Regular : Font = .system(size: 11, weight: .regular)
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

// MARK: - Spacing Tokens (ganti sesuai token system kamu)
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

//MARK: - Illustration Style
extension Image {
    static let beatsheadphones : Image = Image(systemName: "beats.headphones")
        .resizable()
    static let playcirclefill : Image = Image(systemName: "play.circle.fill")
        .resizable()
    static let guitarsfill : Image = Image(systemName: "guitars.fill")
        .resizable()
    static let musicnotelist : Image = Image(systemName: "music.note.list")
        .resizable()
    static let metronomefill : Image = Image(systemName: "metronome.fill")
        .resizable()

}


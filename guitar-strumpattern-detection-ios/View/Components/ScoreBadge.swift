//
//  ScoreBadge.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Score Tier
private enum ScoreTier {
    case high, medium, low

    init(percent: Int) {
        switch percent {
        case 70...: self = .high
        case 40..<70: self = .medium
        default: self = .low
        }
    }

    var textColor: Color {
        switch self {
        case .high:   return .accentGreen
        case .medium: return .accentYellow
        case .low:    return Color(hex: "#E85D5D")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .high:   return Color(hex: "#1E3A1E")
        case .medium: return Color(hex: "#3A3520")
        case .low:    return Color(hex: "#3A1E1E")
        }
    }
}

// MARK: - Score Badge
struct ScoreBadge: View {
    let percent: Int

    private var tier: ScoreTier { ScoreTier(percent: percent) }

    var body: some View {
        Text("\(percent)%")
            .font(AppFont.heading(18))
            .foregroundColor(tier.textColor)
            .frame(width: 56, height: 56)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(tier.backgroundColor)
            )
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        ScoreBadge(percent: 90)
        ScoreBadge(percent: 50)
        ScoreBadge(percent: 20)
    }
    .padding()
    .background(Color.bgPrimary)
}

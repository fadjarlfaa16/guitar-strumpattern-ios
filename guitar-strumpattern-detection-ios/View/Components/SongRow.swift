//
//  SongRow.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Song Row
struct SongRow: View {
    let item: SongListItem
    var onMenuTapped: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.md) {
            ScoreBadge(percent: item.scorePercent)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                metadataRow
                titleRow
            }

            Spacer(minLength: Spacing.sm)

            menuButton
        }
//        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Metadata Row
    private var metadataRow: some View {
        HStack(spacing: Spacing.md) {
            metadataLabel(icon: "stopwatch.fill", text: "= \(item.bpm) bpm")
            metadataLabel(icon: "metronome.fill", text: "= \(item.timeSignature)")
        }
    }

    private func metadataLabel(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.textPrimaryWhite)
            Text(text)
                .font(AppFont.caption1Regular.self)
                .foregroundColor(.textPrimaryWhite)
        }
    }

    // MARK: - Title Row
    private var titleRow: some View {
        Text(item.displayTitle)
            .font(AppFont.caption2Regular.self)
            .foregroundColor(.textPrimaryWhite)

            .lineLimit(1)
            .truncationMode(.tail)
    }

    // MARK: - Menu Button
    private var menuButton: some View {
        Button {
            onMenuTapped?()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimaryWhite)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "Song title",
            artist: "Artist",
            scorePercent: 90
        ))
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "Song title",
            artist: "Artist",
            scorePercent: 50
        ))
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "Song title",
            artist: "Artist",
            scorePercent: 20
        ))
    }
    .padding(.horizontal, 29)
    .background(Color.backgroundPrimaryBlack)
}

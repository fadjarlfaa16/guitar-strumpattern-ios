//
//  SongRow.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Song Row
struct SongRow: View {
    let item: SongListItem
    var isNavigationEnabled = true
    var onMenuTapped: (() -> Void)? = nil
    var onEditTapped: (() -> Void)? = nil
    var onDeleteTapped: (() -> Void)? = nil
    var onAnalyzeTapped: (() -> Void)? = nil

    var body: some View {
        rowContainer
        .contextMenu {
            Button {
                onAnalyzeTapped?()
            } label: {
                Label("Analyze Audio", systemImage: "waveform.circle.fill")
            }
            if onEditTapped != nil {
                Button {
                    onEditTapped?()
                } label: {
                    Label("Edit Name", systemImage: "pencil")
                }
            }
            if onDeleteTapped != nil {
                Button(role: .destructive) {
                    onDeleteTapped?()
                } label: {
                    Label("Delete Song", systemImage: "trash")
                }
            }
        }
    }

    @ViewBuilder
    private var rowContainer: some View {
        if isNavigationEnabled {
            HStack(spacing: Spacing.md) {
                rowContent
                    .background(
                        NavigationLink(value: item.id) {
                            EmptyView()
                        }
                        .opacity(0)
                    )

                menuButton
            }
            .padding(.horizontal, Spacing.lg)
        } else {
            HStack(spacing: Spacing.md) {
                Button {
                    onAnalyzeTapped?()
                } label: {
                    rowContent
                }
                .buttonStyle(.plain)

                menuButton
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(item.title.isEmpty ? "Untitled" : item.title)
                    .font(AppFont.bodyRegular)
                    .foregroundColor(.textPrimaryWhite)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: Spacing.md) {
                    metadataLabel(icon: "stopwatch.fill", text: "= \(item.bpm) bpm")
                    metadataLabel(icon: "metronome.fill", text: "= \(item.timeSignature)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isNavigationEnabled {
                Image(systemName: "waveform.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.brandColorAccentGreen)
            }
        }
    }

    private var menuButton: some View {
        Menu {
            Button {
                onEditTapped?()
            } label: {
                Label("Edit Name", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDeleteTapped?()
            } label: {
                Label("Delete Song", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textSecondary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    private func metadataLabel(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.textPrimaryWhite)
            Text(text)
                .font(AppFont.caption1Regular)
                .foregroundColor(.textPrimaryWhite)
        }
    }
}

#Preview {
    List {
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "Song title",
            artist: "Artist",
            scorePercent: 90
        ))
    }
    .listStyle(.plain)
}

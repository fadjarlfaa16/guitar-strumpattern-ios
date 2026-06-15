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
        VStack(spacing: 0) {
            // Main Row
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Title
                    titleRow
                    
                    // Metadata (BPM & Time Signature)
                    metadataRow
                    
                    // Artist/Album
                    artistRow
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Menu Button
                menuButton
            }
            .padding(.vertical, Spacing.sm)
            
            // Divider
            Divider()
                .background(Color.textPrimaryWhite.opacity(0.5))
        }
    }

    // MARK: - Title Row
    private var titleRow: some View {
        Text(item.displayTitle)
            .font(AppFont.bodyRegular)
            .foregroundColor(.textPrimaryWhite)
            .lineLimit(2)
            .truncationMode(.tail)
    }

    // MARK: - Metadata Row
    private var metadataRow: some View {
        HStack(spacing: Spacing.md) {
            metadataLabel(icon: "clock.fill", text: "= \(item.bpm) bpm")
            metadataLabel(icon: "metronome", text: "= \(item.timeSignature)")
        }
    }

    private func metadataLabel(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(AppFont.bodyBold)
                .foregroundColor(.textPrimaryWhite)
            Text(text)
                .font(AppFont.bodyBold)
                .foregroundColor(.textPrimaryWhite)
        }
    }

    // MARK: - Artist Row
    private var artistRow: some View {
        Text(item.artist)
            .font(AppFont.bodyRegular)
            .foregroundColor(.textPrimaryWhite)
            .lineLimit(2)
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
    VStack(spacing: 0) {
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "The World Is Ugly",
            artist: "My Chemical Romance",
            scorePercent: 90
        ))
        
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "The Fate Of Ophelia",
            artist: "Taylor Swift",
            scorePercent: 50
        ))
        
        SongRow(item: SongListItem(
            bpm: 120,
            timeSignature: "4/4",
            title: "Untungnya, Hidup Harus Terus Berjalan",
            artist: "Bernadya",
            scorePercent: 20
        ))
    }
    .padding(.horizontal, Spacing.xl)
    .background(Color.backgroundPrimaryBlack)
}

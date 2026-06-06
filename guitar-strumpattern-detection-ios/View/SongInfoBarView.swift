// SongInfoBarView.swift
// Komponen bar info lagu: tombol play, BPM, time signature, judul lagu

import SwiftUI

// MARK: - Song Info Bar View
struct SongInfoBarView: View {
    let song: SongInfo
    var onPlayTapped: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            PlayButton(action: onPlayTapped)
            BPMLabel(bpm: song.bpm)
            TimeSignatureLabel(signature: song.timeSignature)
            SongTitleLabel(title: song.displayTitle)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Play Button
struct PlayButton: View {
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.accentGreen)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - BPM Label
struct BPMLabel: View {
    let bpm: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "timer")
                .font(.system(size: 12))
                .foregroundColor(.accentYellow)
            Text("= \(bpm) bpm")
                .font(AppFont.label(13))
                .foregroundColor(.accentYellow)
        }
    }
}

// MARK: - Time Signature Label
struct TimeSignatureLabel: View {
    let signature: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "music.note")
                .font(.system(size: 12))
                .foregroundColor(.accentYellow)
            Text("= \(signature)")
                .font(AppFont.label(13))
                .foregroundColor(.accentYellow)
        }
    }
}

// MARK: - Song Title Label
struct SongTitleLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppFont.body(12))
            .foregroundColor(.accentYellow)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

// MARK: - Preview
#Preview {
    SongInfoBarView(song: .sample)
        .background(Color.bgPrimary)
}

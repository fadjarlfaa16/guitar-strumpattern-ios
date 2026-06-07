// SongInfoBarView.swift


import SwiftUI

// MARK: - Song Info Bar View
struct SongInfoBar: View {
    
    //sample song for test in canvas
    static let sample = SongInfo(
           bpm: 120,
           timeSignature: "4/4",
           displayTitle: "Backburner",
           displayArtist: "Niki"
       )
    let song: SongInfo
    var onPlayTapped: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Spacer()
            PlayButton(action: onPlayTapped)
            BPMLabel(bpm: song.bpm)
            TimeSignatureLabel(signature: song.timeSignature)
            SongTitleLabel(title: song.displayTitle)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Preview
#Preview {
    SongInfoBar(song: SongInfoBar.sample)
        .background(Color.bgPrimary)
}


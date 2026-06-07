//
//  SongListView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Song List View
struct SongListView: View {
    let items: [SongListItem]
    var onMenuTapped: ((SongListItem) -> Void)? = nil

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.md) {
                Text("Song Library")
                    .font(.largeTitle)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(items) { item in
                    SongRow(item: item) {
                        onMenuTapped?(item)
                    }
                }
            }
            .padding(.horizontal, Spacing.xl)
//            .padding(.vertical, Spacing.md)
        }
        .background(Color.bgPrimary)
    }
}

#Preview {
    SongListView(items: SongListItem.samples)
}

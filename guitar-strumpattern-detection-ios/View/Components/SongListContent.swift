//
//  SongListContent.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct SongListContent: View {
    var items: [SongListItem]
    var onMenuTapped: ((SongListItem) -> Void)?
    var onEditTapped: (SongListItem) -> Void
    var onDeleteTapped: (SongListItem) -> Void
    var onAnalyzeTapped: (SongListItem) -> Void

    var body: some View {
        List {
            ForEach(items) { item in
                SongRow(
                    item: item,
                    isNavigationEnabled: item.isAnalyzed,
                    onMenuTapped: { onMenuTapped?(item) },
                    onEditTapped: { onEditTapped(item) },
                    onDeleteTapped: { onDeleteTapped(item) },
                    onAnalyzeTapped: { onAnalyzeTapped(item) }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
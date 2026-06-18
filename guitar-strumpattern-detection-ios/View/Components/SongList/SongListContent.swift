//
//  SongListContent.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//
import SwiftUI


struct SongListContent: View {
    let items: [SongListItem]

    var onEdit: (SongListItem) -> Void
    var onDelete: (SongListItem) -> Void
    var onAnalyze: (UUID) -> Void

    var body: some View {
        List {
            if items.isEmpty {
                Text("No songs available.")
            } else {
                ForEach(items) { item in
                    SongRow(
                        item: item,
                        isNavigationEnabled: item.isAnalyzed,
                        onEditTapped: { onEdit(item) },
                        onDeleteTapped: { onDelete(item) },
                        onAnalyzeTapped: { onAnalyze(item.id) }
                    )
                }
            }
        }
    }
}




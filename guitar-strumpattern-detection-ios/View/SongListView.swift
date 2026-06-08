//
//  SongListView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Song List View
struct SongListView: View {
    let items: [SongListItem]
    var onMenuTapped: ((SongListItem) -> Void)? = nil
    var onAddTapped: (() -> Void)? = nil

    @State private var searchText = ""

    private var filteredItems: [SongListItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return items }
        let lowered = query.lowercased()
        return items.filter {
            $0.title.lowercased().contains(lowered)
                || $0.artist.lowercased().contains(lowered)
        }
    }

    var body: some View {

        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.md) {
                Text("Song Library")
                    .font(.largeTitle)
                    .foregroundColor(.textPrimaryWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)


                    ForEach(filteredItems) { item in
                        SongRow(item: item) {
                            onMenuTapped?(item)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
            }
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        onAddTapped?()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .background(Color.bgPrimary)
    }
}


#Preview {
    SongListView(items: SongListItem.samples)
}

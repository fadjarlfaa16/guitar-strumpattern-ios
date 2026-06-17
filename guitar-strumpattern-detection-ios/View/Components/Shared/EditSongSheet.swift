//
//  EditSongSheet.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

// MARK: - Edit Song Sheet
struct EditSongSheet: View {
    let initialSong: SongListItem
    var onSave: (String, String) -> Void
    var onCancel: () -> Void
    
    @State private var title: String
    @State private var artist: String
    
    
    init(initialSong: SongListItem, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        self.initialSong = initialSong
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initialSong.title)
        _artist = State(initialValue: initialSong.artist)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Song Details")) {
                    TextField("Title", text: $title)
                    TextField("Artist", text: $artist)
                }
            }
            .navigationTitle("Edit Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, artist)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

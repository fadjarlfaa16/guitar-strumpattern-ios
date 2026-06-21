//
//  SongListViewModel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI
import Combine
@MainActor
final class SongListViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var showFilePicker = false
    @Published var uploadError: String?
    @Published var showUploadError = false
    
    @Published var analyzeTarget: AnalyzeTarget?
    
    @Published var editTarget: SongListItem?
    @Published var editTitle = ""
    
    @Published var deleteTarget: SongListItem?
    
    func openAnalysis(for songID: UUID) {
        analyzeTarget = AnalyzeTarget(id: songID)
    }
    
    func openEditSong(_ item: SongListItem) {
        editTarget = item
        editTitle = item.title
    }
    
    func openDeleteSong(_ item: SongListItem) {
        deleteTarget = item
    }
    
    func songTitle(_ item: SongListItem) -> String {
        item.title.isEmpty ? "Untitled" : item.title
    }
    
}

struct AnalyzeTarget: Identifiable {
    let id: UUID
}

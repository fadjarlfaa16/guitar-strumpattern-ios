//
//  SavedSong.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 09/06/26.
//
import Foundation
import Observation

@Observable
final class SavedSong {
    var songs: [SongListItem] = []

    init() {
        loadFromStorage()
    }

    // Load songs from persistent storage
    func loadFromStorage() {
        let allSongs = SongLibraryStore.shared.load()
        UploadLogger.log("loadFromStorage — \(allSongs.count) lagu dari disk")
        songs = allSongs.map { song in
            SongListItem(
                id: song.id,
                bpm: song.bpm ?? 0,
                timeSignature: song.timeSignature ?? "-",
                title: song.title,
                artist: song.artist ?? "Unknown",
                scorePercent: 0,
                sandboxFileName: song.sandboxFileName
            )
        }
    }

    // Add new song from imported file
    func addSong(_ song: Song) {
        UploadLogger.log("addSong — menyimpan '\(song.title)' (\(song.sandboxFileName))")
        var allSongs = SongLibraryStore.shared.load()
        allSongs.append(song)
        SongLibraryStore.shared.save(allSongs)
        loadFromStorage()
        UploadLogger.log("addSong selesai — total \(songs.count) lagu di memori")
    }

    func renameSong(id: UUID, title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        var allSongs = SongLibraryStore.shared.load()
        guard let index = allSongs.firstIndex(where: { $0.id == id }) else { return }

        UploadLogger.log("renameSong — '\(allSongs[index].title)' menjadi '\(trimmedTitle)'")
        allSongs[index].title = trimmedTitle
        SongLibraryStore.shared.save(allSongs)
        loadFromStorage()
    }

    func deleteSong(id: UUID) {
        var allSongs = SongLibraryStore.shared.load()
        guard let song = allSongs.first(where: { $0.id == id }) else { return }

        UploadLogger.log("deleteSong — menghapus '\(song.title)'")
        SongLibraryStore.shared.delete(item: song, from: &allSongs)
        SongLibraryStore.shared.save(allSongs)
        loadFromStorage()
    }
}

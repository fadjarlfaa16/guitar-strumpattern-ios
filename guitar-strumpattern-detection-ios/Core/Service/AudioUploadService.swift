//
//  AudioUploadService.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


//
// AudioUploadService.swift
//

import Foundation

final class AudioUploadService {

    static let shared = AudioUploadService()

    private init() {}

    func upload(
        pickedURL: URL,
        savedSong: SavedSong
    ) async throws -> UUID {

        let filename = pickedURL
            .deletingPathExtension()
            .lastPathComponent

        let ext = pickedURL.pathExtension.isEmpty
            ? "m4a"
            : pickedURL.pathExtension

        let sandboxFileName =
            "\(UUID().uuidString).\(ext)"

        let destination =
            SongLibraryStore.audioDirectory
            .appendingPathComponent(sandboxFileName)

        let didStartAccessing =
            pickedURL.startAccessingSecurityScopedResource()

        defer {
            if didStartAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }

        try FileManager.default.copyItem(
            at: pickedURL,
            to: destination
        )

        let duration =
            await AudioMetadataService.shared.duration(
                url: destination
            )

        let song = Song(
            title: filename,
            artist: "Unknown Artist",
            sandboxFileName: sandboxFileName,
            duration: duration
        )

        savedSong.addSong(song)

        return song.id
    }
}
//
//  SongLibraryStore.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 06/06/26.
//


import Foundation

final class SongLibraryStore {

    static let shared = SongLibraryStore()
    private init() {}

    static var audioDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SongLibrary", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var metadataURL: URL {
        Self.audioDirectory.appendingPathComponent("library.json")
    }

    // Load Song Library
    func load() -> [Song] {
        guard let data = try? Data(contentsOf: metadataURL),
              let items = try? JSONDecoder().decode([Song].self, from: data) else {
            return []
        }
        return items
    }
    
    // Save current song
    func save(_ items: [Song]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: metadataURL, options: .atomic)
    }

    // Extract Audio URL from device
    func audioURL(for item: Song) -> URL {
        Self.audioDirectory.appendingPathComponent(item.sandboxFileName)
    }
    
    // Import song from URL
    func importAudio(from sourceURL: URL) throws -> String {
        let ext = sourceURL.pathExtension
        let sandboxFileName = "\(UUID().uuidString).\(ext)"
        let destination = Self.audioDirectory.appendingPathComponent(sandboxFileName)

        let accessing = sourceURL.startAccessingSecurityScopedResource()
        defer { if accessing { sourceURL.stopAccessingSecurityScopedResource() } }

        try FileManager.default.copyItem(at: sourceURL, to: destination)
        return sandboxFileName
    }

    /// Delete Song
    func delete(item: Song, from items: inout [Song]) {
        let url = audioURL(for: item)
        try? FileManager.default.removeItem(at: url)
        items.removeAll { $0.id == item.id }
    }
}

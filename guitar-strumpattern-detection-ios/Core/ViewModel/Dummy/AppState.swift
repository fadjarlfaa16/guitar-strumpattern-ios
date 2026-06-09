//
//  SavedSong.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 09/06/26.
//
import Observation


@Observable
final class AppState {
    var savedSongs: [SongListItem] = []
    var isFirst: Bool = true
}


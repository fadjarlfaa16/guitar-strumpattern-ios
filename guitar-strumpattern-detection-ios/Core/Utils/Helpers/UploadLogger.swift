//
//  UploadLogger.swift
//  guitar-strumpattern-detection-ios
//

import Foundation

/// Logger untuk alur upload audio. Cari prefix `[Upload]` di Xcode console.
enum UploadLogger {
    private static let prefix = "[Upload]"

    static func log(
        _ message: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        let name = (file as NSString).lastPathComponent
        print("\(prefix) \(name):\(line) \(function) — \(message)")
    }

    static func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        var text = message
        if let error { text += " | \(error.localizedDescription)" }
        log("ERROR: \(text)", file: file, line: line, function: function)
    }
}

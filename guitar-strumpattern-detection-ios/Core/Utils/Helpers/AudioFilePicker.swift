//
//  AudioFilePicker.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Muhammad Fadjar Al Farisyi on 09/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct AudioFilePicker: UIViewControllerRepresentable {
    /// Dipanggil saat user memilih file. Parent menutup sheet lewat binding `showFilePicker`.
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            UTType.audio,
            UTType(filenameExtension: "mp3") ?? .audio,
            UTType(filenameExtension: "m4a") ?? .audio,
            UTType(filenameExtension: "wav") ?? .audio
        ])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                UploadLogger.log("Picker dismissed tanpa file")
                return
            }
            UploadLogger.log("File dipilih: \(url.lastPathComponent) | scheme=\(url.scheme ?? "-")")
            DispatchQueue.main.async { self.onPick(url) }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            UploadLogger.log("Picker dibatalkan user")
        }
    }
}


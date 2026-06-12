//
//  SongListView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI
import AVFoundation

// MARK: - Song List View
struct SongListView: View {
    var onMenuTapped: ((SongListItem) -> Void)? = nil
    var onAddTapped: (() -> Void)? = nil
    let isFirstTime: Bool = false

    @State private var searchText = ""
    @State private var showFilePicker = false
    @State private var uploadError: String? = nil
    @State private var showUploadError = false
    @State private var analyzeTarget: AnalyzeTarget? = nil
    @State private var editTarget: SongListItem? = nil
    @State private var editTitle = ""
    @State private var deleteTarget: SongListItem? = nil
    @State private var showCalibrate = false

    @AppStorage("appState") private var appState: AppState = .songList
    @Environment(SavedSong.self) private var savedSong

    private var filteredItems: [SongListItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return savedSong.songs }
        let lowered = query.lowercased()
        return savedSong.songs.filter {
            $0.title.lowercased().contains(lowered)
                || $0.artist.lowercased().contains(lowered)
        }
    }

    private var editAlertBinding: Binding<Bool> {
        Binding(
            get: { editTarget != nil },
            set: { isPresented in
                if !isPresented {
                    editTarget = nil
                    editTitle = ""
                }
            }
        )
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { deleteTarget != nil },
            set: { isPresented in
                if !isPresented {
                    deleteTarget = nil
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.md)

            if savedSong.songs.isEmpty {
                Spacer()
                emptyStateView
                Spacer()
            } else if isFirstTime {
                Spacer()
                firstTimeView
                Spacer()
            } else {
                songList
            }
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showFilePicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showFilePicker) {
            AudioFilePicker { pickedURL in
                Task { @MainActor in
                    showFilePicker = false
                    if let songID = await performAudioUpload(pickedURL) {
                        analyzeTarget = AnalyzeTarget(id: songID)
                    }
                }
            }
        }
        .alert("Upload Error", isPresented: $showUploadError) {
            Button("OK") {
                uploadError = nil
                showUploadError = false
            }
        } message: {
            if let error = uploadError {
                Text(error)
            }
        }
        .alert("Edit Song Name", isPresented: editAlertBinding) {
            TextField("Song name", text: $editTitle)
            Button("Cancel", role: .cancel) {
                editTarget = nil
                editTitle = ""
            }
            Button("Save") {
                if let editTarget {
                    savedSong.renameSong(id: editTarget.id, title: editTitle)
                }
                editTarget = nil
                editTitle = ""
            }
        } message: {
            Text("Update the title shown in your song library.")
        }
        .alert("Delete Song?", isPresented: deleteAlertBinding) {
            Button("Cancel", role: .cancel) {
                deleteTarget = nil
            }
            Button("Delete", role: .destructive) {
                if let deleteTarget {
                    savedSong.deleteSong(id: deleteTarget.id)
                }
                deleteTarget = nil
            }
        } message: {
            if let deleteTarget {
                Text("This will remove \"\(songTitle(deleteTarget))\" from your library.")
            }
        }
        .fullScreenCover(item: $analyzeTarget) { target in
            if let song = SongLibraryStore.shared.load().first(where: { $0.id == target.id }) {
                AnalyzeMusicModal(
                    song: song,
                    onAnalysisComplete: { result in
                        var allSongs = SongLibraryStore.shared.load()
                        if let index = allSongs.firstIndex(where: { $0.id == target.id }) {
                            allSongs[index].bpm = result.bpm
                            allSongs[index].timeSignature = result.timeSignature
                            allSongs[index].chordSegments = result.chordSegments
                            SongLibraryStore.shared.save(allSongs)
                            savedSong.loadFromStorage()
                        }
                    },
                    onDismiss: {
                        analyzeTarget = nil
                    }
                )
            }
        }
        .searchable(text: $searchText, prompt: "Search")
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.bgPrimary)
        .navigationDestination(for: UUID.self) { songID in
            songDetailView(for: songID)
        }
        .navigationDestination(isPresented: $showCalibrate) {
            CalibrateView()
        }
    }

    // MARK: - Song List

    private var songList: some View {
        List {
            ForEach(filteredItems) { item in
                SongRow(
                    item: item,
                    isNavigationEnabled: item.isAnalyzed,
                    onMenuTapped: { onMenuTapped?(item) },
                    onEditTapped: { openEditSong(for: item) },
                    onDeleteTapped: { openDeleteSong(for: item) },
                    onAnalyzeTapped: { openAnalysis(for: item.id) }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Song Library")
                .font(.largeTitle)
                .foregroundColor(.textPrimaryWhite)
                .bold()

            Spacer()

            Button {
                showCalibrate = true
            } label: {
                Label("Kalibrasi", systemImage: "applewatch")
                    .font(AppFont.bodyRegular)
                    .foregroundStyle(.textPrimaryWhite)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyStateView: some View {
        VStack {
            Image.musicnotelist
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.textSecondary)

            VStack {
                Text("Your library is empty")
                    .font(AppFont.title3Bold)
                    .foregroundColor(.textSecondary)
                    .padding(.top, Spacing.xs)
                Text("Press + to add a song, then swipe left to analyze")
                    .font(AppFont.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .padding(.horizontal, Spacing.xl)
    }

    private var firstTimeView: some View {
        VStack(spacing: Spacing.md) {
            Image.musicnotelist
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.textSecondary)

            Text("Finish your tutorial first")
                .font(AppFont.bodyRegular)
                .foregroundColor(.textSecondary)
                .padding(.top, Spacing.xs)

            CustomButton(title: "Do Tutorial") {
                appState = .onboarding
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.sm)
        }
        .padding(.horizontal, Spacing.xl)
    }

    // MARK: - Actions

    private func openAnalysis(for songID: UUID) {
        analyzeTarget = AnalyzeTarget(id: songID)
    }

    private func openEditSong(for item: SongListItem) {
        editTarget = item
        editTitle = item.title
        onMenuTapped?(item)
    }

    private func openDeleteSong(for item: SongListItem) {
        deleteTarget = item
        onMenuTapped?(item)
    }

    private func songTitle(_ item: SongListItem) -> String {
        item.title.isEmpty ? "Untitled" : item.title
    }

    @MainActor
    private func performAudioUpload(_ pickedURL: URL) async -> UUID? {
        uploadError = nil
        UploadLogger.log("performAudioUpload MULAI — \(pickedURL.lastPathComponent)")

        let filename = pickedURL.deletingPathExtension().lastPathComponent
        let ext = pickedURL.pathExtension.isEmpty ? "m4a" : pickedURL.pathExtension
        let sandboxFileName = "\(UUID().uuidString).\(ext)"
        let destination = SongLibraryStore.audioDirectory.appendingPathComponent(sandboxFileName)

        UploadLogger.log("Target sandbox: \(destination.path)")

        let didStartAccessing = pickedURL.startAccessingSecurityScopedResource()
        UploadLogger.log("Security-scoped access: \(didStartAccessing ? "granted" : "not needed/failed")")
        defer {
            if didStartAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
                UploadLogger.log("Security-scoped access released")
            }
        }

        do {
            UploadLogger.log("copyItem mulai…")
            try FileManager.default.copyItem(at: pickedURL, to: destination)
            let size = (try? FileManager.default.attributesOfItem(atPath: destination.path)[.size] as? Int64) ?? 0
            UploadLogger.log("copyItem berhasil — \(size) bytes")
        } catch {
            UploadLogger.error("copyItem gagal", error: error)
            uploadError = "Gagal menyalin file: \(error.localizedDescription)"
            showUploadError = true
            return nil
        }

        let audioURL = SongLibraryStore.audioDirectory.appendingPathComponent(sandboxFileName)
        UploadLogger.log("Membaca durasi audio (timeout 8s)…")
        let duration = await loadAudioDuration(url: audioURL, timeoutSeconds: 8)
        UploadLogger.log("Durasi: \(duration)s")

        let newSong = Song(
            title: filename,
            artist: "Unknown Artist",
            sandboxFileName: sandboxFileName,
            duration: duration
        )

        savedSong.addSong(newSong)
        UploadLogger.log("Upload sukses — lagu '\(filename)' ada di library, lanjut analisis")
        return newSong.id
    }

    /// AVURLAsset.load(.duration) bisa hang pada beberapa format — pakai timeout.
    private func loadAudioDuration(url: URL, timeoutSeconds: Int) async -> TimeInterval {
        enum DurationResult {
            case value(TimeInterval)
            case timeout
            case failed(Error)
        }

        let result = await withTaskGroup(of: DurationResult.self) { group in
            group.addTask {
                do {
                    let seconds = try await AVURLAsset(url: url).load(.duration).seconds
                    return .value(seconds)
                } catch {
                    return .failed(error)
                }
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(timeoutSeconds) * 1_000_000_000)
                return .timeout
            }

            let first = await group.next() ?? .timeout
            group.cancelAll()
            return first
        }

        switch result {
        case .value(let seconds):
            guard seconds.isFinite, seconds >= 0 else {
                UploadLogger.log("Durasi tidak valid, pakai 0")
                return 0
            }
            return seconds
        case .timeout:
            UploadLogger.log("Durasi timeout setelah \(timeoutSeconds)s — pakai 0")
            return 0
        case .failed(let error):
            UploadLogger.error("Durasi gagal dibaca", error: error)
            return 0
        }
    }

    @ViewBuilder
    private func songDetailView(for songID: UUID) -> some View {
        if let stored = SongLibraryStore.shared.load().first(where: { $0.id == songID }) {
            if let bpm = stored.bpm,
               bpm > 0,
               let timeSignature = stored.timeSignature,
               let chordSegments = stored.chordSegments,
               !chordSegments.isEmpty {
                let audioURL = SongLibraryStore.audioDirectory
                    .appendingPathComponent(stored.sandboxFileName)
                ChooseStrummingPatternView(
                    bpm: bpm,
                    rhythm: timeSignature,
                    patterns: StrummingPattern.samples,
                    chordSegments: chordSegments,
                    audioURL: audioURL
                )
            } else {
                ContentUnavailableView("Analyze Song First", systemImage: "waveform.circle")
            }
        } else {
            ContentUnavailableView("Song Not Found", systemImage: "music.note.list")
        }
    }
}

// MARK: - Analyze Target (ringan untuk fullScreenCover)

private struct AnalyzeTarget: Identifiable {
    let id: UUID
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SongListView()
            .environment(SavedSong())
    }
}

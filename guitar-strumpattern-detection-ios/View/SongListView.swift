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

    // MARK: - State
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
    @AppStorage("isFirstLaunch") private var isFirstTime: Bool = true
    @Environment(SavedSong.self) private var savedSong

    // MARK: - Filtered Items

    private var filteredItems: [SongListItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return savedSong.songs }
        let lowered = query.lowercased()
        return savedSong.songs.filter {
            $0.title.lowercased().contains(lowered)
                || $0.artist.lowercased().contains(lowered)
        }
    }

    // MARK: - Alert Bindings

    private var editAlertBinding: Binding<Bool> {
        Binding(
            get: { editTarget != nil },
            set: { if !$0 { editTarget = nil; editTitle = "" } }
        )
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { deleteTarget != nil },
            set: { if !$0 { deleteTarget = nil } }
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SongListHeader(onCalibrateTapped: { showCalibrate = true })
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.md)
            WatchStatusView()
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.md)
            if isFirstTime {
                Spacer()
                firstTimeView
                Spacer()
            } else if savedSong.songs.isEmpty {
                Spacer()

                emptyStateView
                Spacer()
            } else {
                SongListContent(
                    items: filteredItems,
                    onMenuTapped: onMenuTapped,
                    onEditTapped: { openEditSong(for: $0) },
                    onDeleteTapped: { openDeleteSong(for: $0) },
                    onAnalyzeTapped: { openAnalysis(for: $0.id) }
                )
            }
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button { showFilePicker = true } label: {
                    Image(systemName: "plus")
                }
                .disabled(isFirstTime)
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
            Button("OK") { uploadError = nil; showUploadError = false }
        } message: {
            if let error = uploadError { Text(error) }
        }
        .alert("Edit Song Name", isPresented: editAlertBinding) {
            TextField("Song name", text: $editTitle)
            Button("Cancel", role: .cancel) { editTarget = nil; editTitle = "" }
            Button("Save") {
                if let editTarget { savedSong.renameSong(id: editTarget.id, title: editTitle) }
                editTarget = nil; editTitle = ""
            }
        } message: {
            Text("Update the title shown in your song library.")
        }
        .alert("Delete Song?", isPresented: deleteAlertBinding) {
            Button("Cancel", role: .cancel) { deleteTarget = nil }
            Button("Delete", role: .destructive) {
                if let deleteTarget { savedSong.deleteSong(id: deleteTarget.id) }
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
                    onDismiss: { analyzeTarget = nil }
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

//            Button {
//                showCalibrate = true
//            } label: {
//                Label("Kalibrasi", systemImage: "applewatch")
//                    .font(AppFont.bodyRegular)
//                    .foregroundStyle(.textPrimaryWhite)
//            }
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

    // MARK: - Audio Upload

    @MainActor
    private func performAudioUpload(_ pickedURL: URL) async -> UUID? {
        uploadError = nil
        UploadLogger.log("performAudioUpload MULAI — \(pickedURL.lastPathComponent)")

        let filename = pickedURL.deletingPathExtension().lastPathComponent
        let ext = pickedURL.pathExtension.isEmpty ? "m4a" : pickedURL.pathExtension
        let sandboxFileName = "\(UUID().uuidString).\(ext)"
        let destination = SongLibraryStore.audioDirectory.appendingPathComponent(sandboxFileName)

        let didStartAccessing = pickedURL.startAccessingSecurityScopedResource()
        defer { if didStartAccessing { pickedURL.stopAccessingSecurityScopedResource() } }

        do {
            try FileManager.default.copyItem(at: pickedURL, to: destination)
        } catch {
            uploadError = "Gagal menyalin file: \(error.localizedDescription)"
            showUploadError = true
            return nil
        }

        let audioURL = SongLibraryStore.audioDirectory.appendingPathComponent(sandboxFileName)
        let duration = await loadAudioDuration(url: audioURL, timeoutSeconds: 8)

        let newSong = Song(
            title: filename,
            artist: "Unknown Artist",
            sandboxFileName: sandboxFileName,
            duration: duration
        )
        savedSong.addSong(newSong)
        return newSong.id
    }

    private func loadAudioDuration(url: URL, timeoutSeconds: Int) async -> TimeInterval {
        enum R { case value(TimeInterval), timeout, failed(Error) }
        let result = await withTaskGroup(of: R.self) { group in
            group.addTask {
                do { return .value(try await AVURLAsset(url: url).load(.duration).seconds) }
                catch { return .failed(error) }
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
        case .value(let s) where s.isFinite && s >= 0: return s
        default: return 0
        }
    }

    // MARK: - Song Detail

    @ViewBuilder
    private func songDetailView(for songID: UUID) -> some View {
        if let stored = SongLibraryStore.shared.load().first(where: { $0.id == songID }),
           let bpm = stored.bpm, bpm > 0,
           let timeSignature = stored.timeSignature,
           let chordSegments = stored.chordSegments, !chordSegments.isEmpty {
            let audioURL = SongLibraryStore.audioDirectory.appendingPathComponent(stored.sandboxFileName)
            let recommendedPatterns = StrumPatternLibrary.recommendations(
                bpm: bpm, timeSignature: timeSignature, chordSegments: chordSegments
            )
            ChooseStrummingPatternView(
                bpm: bpm,
                rhythm: timeSignature,
                patterns: recommendedPatterns,
                chordSegments: chordSegments,
                audioURL: audioURL
            )
        } else if SongLibraryStore.shared.load().first(where: { $0.id == songID }) != nil {
            ContentUnavailableView("Analyze Song First", systemImage: "waveform.circle")
        } else {
            ContentUnavailableView("Song Not Found", systemImage: "music.note.list")
        }
    }
}

// MARK: - Analyze Target

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

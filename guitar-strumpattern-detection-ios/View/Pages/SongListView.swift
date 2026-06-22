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
    @StateObject private var viewModel = SongListViewModel()
    @State private var showRecalibrate = false
    @AppStorage("navRoot") private var navRoot: NavRoot = .songList
    @AppStorage("isFirstLaunch") private var isFirstTime: Bool = false
    @AppStorage("shouldShowFilePickerOnLoad") private var shouldShowFilePickerOnLoad = false
    @Environment(SavedSong.self) private var savedSong

    private var filteredItems: [SongListItem] {
        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return savedSong.songs }
        let lowered = query.lowercased()
        return savedSong.songs.filter {
            $0.title.lowercased().contains(lowered)
                || $0.artist.lowercased().contains(lowered)
        }
    }

    private var editAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.editTarget != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.editTarget = nil
                    viewModel.editTitle = ""
                }
            }
        )
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.deleteTarget != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.deleteTarget = nil
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SongListHeader()
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.md)
            if isFirstTime {
                Spacer()
                SongListFirstTimeState {
                    navRoot = .onboarding
                }
                Spacer()
            } else if savedSong.songs.isEmpty {
                VStack {
                        Spacer()
                        SongListEmptyState()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
            } else {
                SongListContent(
                    items: filteredItems,
                    onEdit: viewModel.openEditSong,
                    onDelete: viewModel.openDeleteSong,
                    onAnalyze: viewModel.openAnalysis
                )
            }
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    viewModel.showFilePicker = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(isFirstTime)
            }
        }
        .sheet(isPresented: $viewModel.showFilePicker) {
            AudioFilePicker { pickedURL in
                Task { @MainActor in
                    viewModel.showFilePicker = false

                    do {
                        let songID = try await AudioUploadService.shared.upload(
                            pickedURL: pickedURL,
                            savedSong: savedSong
                        )

                        viewModel.analyzeTarget = AnalyzeTarget(id: songID)

                    } catch {
                        viewModel.uploadError = error.localizedDescription
                        viewModel.showUploadError = true
                    }
                }
            }
        }
        .alert("Upload Error", isPresented: $viewModel.showUploadError) {
            Button("OK") {
                viewModel.uploadError = nil
                viewModel.showUploadError = false
            }
        } message: {
            if let error = viewModel.uploadError {
                Text(error)
            }
        }
        .alert("Edit Song Name", isPresented: editAlertBinding) {
            TextField("Song name", text: $viewModel.editTitle)
            Button("Cancel", role: .cancel) {
                viewModel.editTarget = nil
                viewModel.editTitle = ""
            }
            Button("Save") {
                if let editTarget = viewModel.editTarget  {
                    savedSong.renameSong(id: editTarget.id, title: viewModel.editTitle)
                }
                viewModel.editTarget = nil
                viewModel.editTitle = ""
            }
        } message: {
            Text("Update the title shown in your song library.")
        }
        .alert("Delete Song?", isPresented: deleteAlertBinding) {
            Button("Cancel", role: .cancel) {
                viewModel.deleteTarget = nil
            }
            Button("Delete", role: .destructive) {
                if let deleteTarget = viewModel.deleteTarget {
                    savedSong.deleteSong(id: deleteTarget.id)
                }
                viewModel.deleteTarget = nil
            }
        } message: {
            if let deleteTarget = viewModel.deleteTarget {
                Text("This will remove \"\(viewModel.songTitle(deleteTarget))\" from your library.")
            }
        }
        .fullScreenCover(item: $viewModel.analyzeTarget) { target in
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
                        viewModel.analyzeTarget = nil
                    }
                )
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search")
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.bgPrimary)

        .navigationDestination(for: UUID.self) { songID in
            SongDetailDestination(songID: songID)
        }
        .navigationDestination(isPresented: $showRecalibrate) {
            CalibrateWatchView(isRecalibrating: true)
        }
        .onAppear {
            if shouldShowFilePickerOnLoad {
                viewModel.showFilePicker = true
                shouldShowFilePickerOnLoad = false
            }
        }
    }
}



// MARK: - Preview

#Preview {
    let savedSong = SavedSong()

    NavigationStack {
        SongListView()
            .environment(savedSong)
    }
}


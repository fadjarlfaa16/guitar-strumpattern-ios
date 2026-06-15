//
//  SongListView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

// MARK: - Song List View
struct SongListView: View {
    var onMenuTapped: ((SongListItem) -> Void)? = nil
    var onAddTapped: (() -> Void)? = nil

    // State untuk Search dan UI
    @State private var searchText = ""
    @State private var showEmptyState = false
    @State private var songToEdit: SongListItem? = nil

    // State Navigasi Global
    @AppStorage("appState") private var navRoot: NavRoot = .songList
    @Environment(AppState.self) private var appState

    private var filteredItems: [SongListItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return items }
        let lowered = query.lowercased()
        return items.filter {
            $0.title.lowercased().contains(lowered)
                || $0.artist.lowercased().contains(lowered)
        }
    }

    private var items: [SongListItem] {
        appState.savedSongs
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. Header (Statis di atas)
            headerView
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.md)
            
            // 2. Area Konten Utama
            if items.isEmpty {
                // Tampilan Empty State
                VStack {
                    Spacer()
                    emptyStateView
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if(appState.isFirstTime) {
                VStack {
                    Spacer()
                    firstTimeView
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Tampilan List Lagu Asli
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredItems) { item in
                            SongRow(
                                item: item,
                                onMenuTapped: {
                                    // Tindakan asli tidak diperlukan karena akan ditangkap oleh overlay Menu di bawahnya
                                    onMenuTapped?(item)
                                }
                            )
                            .overlay(alignment: .trailing) {
                                // Invisible Menu overlay di atas tombol ellipsis
                                Menu {
                                    Button {
                                        // Aksi Edit
                                        songToEdit = item
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        // Aksi Delete
                                        if let index = appState.savedSongs.firstIndex(where: { $0.id == item.id }) {
                                            appState.savedSongs.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Color.white.opacity(0.001) // transparan tapi bisa di-tap
                                        .frame(width: 60, height: 80)
                                }
                                .offset(y: -8) // adjust sedikit ke atas karena ada divider di bawah SongRow
                            }
                        }
                    }
                    .padding(.top, Spacing.sm)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.md)
                }
                Button("Reset") {
                    appState.savedSongs.removeAll()
                    appState.isFirstTime = true
                    navRoot = .onboarding
                }
            }
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    if(appState.savedSongs.isEmpty) {
                        appState.savedSongs.append(contentsOf: SongListItem.samples)
                    } else {
                        appState.savedSongs.removeAll()
                    }
                    onAddTapped?()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search")
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.bgPrimary)
        .sheet(item: $songToEdit) { song in
            EditSongSheet(initialSong: song) { newTitle, newArtist in
                if let index = appState.savedSongs.firstIndex(where: { $0.id == song.id }) {
                    let updatedSong = SongListItem(
                        id: song.id,
                        bpm: appState.savedSongs[index].bpm,
                        timeSignature: appState.savedSongs[index].timeSignature,
                        title: newTitle,
                        artist: newArtist,
                        scorePercent: song.scorePercent
                    )
                    appState.savedSongs[index] = updatedSong
                }
                songToEdit = nil
            } onCancel: {
                songToEdit = nil
            }
        }
        .navigationDestination(for: SongListItem.self) { song in
            ChooseStrummingPatternView(
                bpm: song.bpm,
                rhythm: song.timeSignature,
                patterns: StrummingPattern.samples
            )
        }
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        HStack {
            Text("Song Library")
                .font(.largeTitle)
                .foregroundColor(.textPrimaryWhite)
                .bold()
            
            Spacer()
            
            // Tombol toggle (Untuk testing UI Show/Hide Empty State)
            Button {
                withAnimation(.easeInOut) {
                    showEmptyState.toggle()
                }
            } label: {
                Image(systemName: showEmptyState ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.textSecondary) // Menggunakan token textSecondary
                    .imageScale(.medium)
                    .padding(.leading, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Empty State View Component
    private var emptyStateView: some View {
        VStack() {
            Image.musicnotelist
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.textSecondary)
            
            VStack {
                Text("Your library is empty")
                    .font(AppFont.title3Bold)
                    .foregroundColor(.textSecondary)
                    .padding(.top, Spacing.xs)
                Text("Press + to add a new song to the library")
                    .font(AppFont.bodyRegular)
                    .foregroundColor(.textSecondary)
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
            
            // CTA Button yang mengubah AppState kembali ke Onboarding
            CustomButton(title: "Do Tutorial") {
                navRoot = .onboarding
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.sm)
        }
        .padding(.horizontal, Spacing.xl)
    }
}

// MARK: - Edit Song Sheet
struct EditSongSheet: View {
    let initialSong: SongListItem
    var onSave: (String, String) -> Void
    var onCancel: () -> Void
    
    @State private var title: String
    @State private var artist: String
    
    
    init(initialSong: SongListItem, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        self.initialSong = initialSong
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initialSong.title)
        _artist = State(initialValue: initialSong.artist)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Song Details")) {
                    TextField("Title", text: $title)
                    TextField("Artist", text: $artist)
                }
            }
            .navigationTitle("Edit Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, artist)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Preview
#Preview {
    // Dibungkus NavigationStack agar toolbar dan navigasinya ter-render di Canvas
    NavigationStack {
        SongListView()
            .environment(AppState())
    }
}

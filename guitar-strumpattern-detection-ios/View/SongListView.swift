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
                    LazyVStack(alignment: .leading, spacing: Spacing.md) {
                        ForEach(filteredItems) { item in
                            SongRow(
                                item: item,
                                onMenuTapped: { onMenuTapped?(item) }
                            )
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

// MARK: - Preview
#Preview {
    // Dibungkus NavigationStack agar toolbar dan navigasinya ter-render di Canvas
    NavigationStack {
        SongListView()
            .environment(AppState())
    }
}

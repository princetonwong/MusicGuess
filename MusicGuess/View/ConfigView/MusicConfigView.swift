//
//  MusicConfigView.swift
//  MusicGuess
//
//  Created by Princeton Wong on 16/7/2022.
//

import SwiftUI
import SwiftUILayouts
import CollectionViewPagingLayout
import ASCollectionView
import MusicKit

enum DetailDestination: String, CaseIterable, Identifiable {
    case search, preloaded, charts
    
    var id: Self { self }
}

enum SearchScope: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case topResults = "Top Results"
    case Artists
    case Albums
    case Playlists
}

struct MusicConfigView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject private var appStorage: AppStorage
    
    @StateObject private var viewModel = MusicConfigViewModel()
    
    @State private var musicItems: [PlayableMusicItem] = []
    @State private var selectedMusicItems: [PlayableMusicItem] = []
    @State private var destination: DetailDestination?
    
    @State private var searchSubmitted: Bool = false
    
    var body: some View {
        NavigationSplitView{} content: {
            VStack {
                List(selection: $destination) {
                    ForEach(DetailDestination.allCases) { d in
                        label(d)
                    }
                    MusicItemSection(title: "Selected Items", items: MusicItemCollection(selectedMusicItems)) { item in
                        // Change to collection or grid
                        MultiSelectRow(item: item, selectedItems: $selectedMusicItems)
                    }
                    .padding(.bottom)
                }
                .navigationTitle("Select Music")
                .toolbar() {
                    Button("Start Game", action: {
                        Task {await startGame()
                        }
                    })}
                .frame(minHeight: 200)
                
                
            }
        } detail: {
            NavigationStack {
                switch destination {
                case .preloaded: preloadedList
                case .charts: EmptyView()
                case .search: searchDetailListView
                case .none: EmptyView()
                }
            }
        }
        .navigationSplitViewColumnWidth(600)
//        .onChange(of: searchScope) {scope in viewModel.runSearch(searchScope: scope)}
        .onAppear {musicItems = musicManager.preloadedMusicItems}
    }
    
    @ViewBuilder
    func label(_ d: DetailDestination) -> some View {
        switch d {
        case .preloaded: Label("Preloaded", systemImage: "info.circle.fill")
        case .charts: Label("Charts", systemImage: "chart.bar.fill")
        case .search: Label("Search", systemImage: "magnifyingglass")
        }
    }
    
    @ViewBuilder
    private var personalRecommendationsList: some View {
        List {
            MusicItemSection(title: "Personal Recommendations", items: viewModel.recommendedPlaylists) { item in
                MultiSelectRow(item: PlayableMusicItem.playlist(item), selectedItems: $selectedMusicItems)
            }
        }
    }
    
    
    @ViewBuilder
    private var preloadedList: some View {
        List {
            MusicItemSection(title: "Preloaded Items", items: MusicItemCollection(musicManager.preloadedMusicItems)) { item in
                MultiSelectRow(item: item, selectedItems: $selectedMusicItems)
            }
        }
    }
    
    @ViewBuilder
    private var searchDetailListView: some View {
        SearchDetailList(selectedMusicItems: $selectedMusicItems, searchSubmitted: $searchSubmitted)
            .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                viewModel.requestSearchCatalog(for: viewModel.searchTerm)
                searchSubmitted = true
            }
            .searchScopes($viewModel.searchScope) {
                ForEach(SearchScope.allCases) { scope in
                    Text(scope.rawValue.capitalized).tag(scope)
                }
            }
            .animation(.default, value: viewModel.recommendedPlaylists)
            .animation(.default, value: viewModel.searchSuggestionsResponse)
            .environmentObject(viewModel)
    }
    
    struct SearchDetailList: View {
        @Environment(\.isSearching) var isSearching
        @Environment(\.dismissSearch) var dismissSearch
        @EnvironmentObject var viewModel: MusicConfigViewModel
        @Binding var selectedMusicItems: [PlayableMusicItem]
        @Binding var searchSubmitted: Bool
        
        var body: some View {
            List {
                if isSearching {
                    if !searchSubmitted {
                        if let searchSuggestionsResponse = viewModel.searchSuggestionsResponse {
                            // Suggested keywords
                            ForEach(searchSuggestionsResponse.suggestions, id: \.self) { suggestion in
                                Text(suggestion.displayTerm)
                                    .onTapGesture {
                                        viewModel.searchTerm = suggestion.displayTerm
                                    }
                            }
                            
                            MusicItemSection(title: "Top Results", items: searchSuggestionsResponse.topResults) { topResult in
                                topResult.multiSelectRow(selectedItems: $selectedMusicItems)
                                
                            }
                        }
                    } else {
                        if let searchResponse = viewModel.searchResponse {
                            switch viewModel.searchScope {
                            case .topResults:
                                MusicItemSection(title: "Top Results", items: searchResponse.topResults) { topResult in
                                    topResult.multiSelectRow(selectedItems: $selectedMusicItems)
                                    
                                }
                            case .Albums:
                                MusicItemSection(title: "Search Results", items: searchResponse.albums) { topResult in
                                    topResult.multiSelectRow(selectedItems: $selectedMusicItems)
                                }
                            case .Playlists:
                                MusicItemSection(title: "Search Results", items: searchResponse.playlists) { topResult in
                                    topResult.multiSelectRow(selectedItems: $selectedMusicItems)
                                }
                            case .Artists:
                                MusicItemSection(title: "Search Results", items: searchResponse.artists) { topResult in
                                    topResult.multiSelectRow(selectedItems: $selectedMusicItems)
                                }
                            }
                        }
                    }
                }
            }
        }
            
    }
    
    private func startGame() async {
        var categories: [Category] = []
        for item in selectedMusicItems {
            switch item {
            case .artist(let artist):
                if let v = await viewModel.produceCategoryWithArtistTopSongs(from: artist) {
                    categories.append(v)
                }
            case .album(let album):
                if let v = await viewModel.produceCategoryWithAlbum(from: album) {
                    categories.append(v)
                }
            case .playlist(let playlist):
                if let v = await viewModel.produceCategoryWithPlaylist(from: playlist) {
                    categories.append(v)
                }
            }
        }
        
        await appStorage.updateClueSet(categories: categories)
        
        //        Task {
        if let clueSet = appStorage.clueSet, !clueSet.roundCategories.isEmpty {
            let game = Game(clueSet: clueSet, players: appStorage.recentPlayers)
            appState.currentViewKey = .game(game)
        //            }
    }
        }
}

extension Album {
    @ViewBuilder
    func multiSelectRow(selectedItems: Binding<[PlayableMusicItem]>) -> some View {
        MultiSelectRow(item: PlayableMusicItem.album(self), selectedItems: selectedItems)
    }
}

extension Playlist {
    @ViewBuilder
    func multiSelectRow(selectedItems: Binding<[PlayableMusicItem]>) -> some View {
        MultiSelectRow(item: PlayableMusicItem.playlist(self), selectedItems: selectedItems)
    }
}

extension Artist {
    @ViewBuilder
    func multiSelectRow(selectedItems: Binding<[PlayableMusicItem]>) -> some View {
        MultiSelectRow(item: PlayableMusicItem.artist(self), selectedItems: selectedItems)
    }
}

extension MusicCatalogSearchResponse.TopResult {
    
    @ViewBuilder
    func multiSelectRow(selectedItems: Binding<[PlayableMusicItem]>) -> some View {
        switch self {
        case .album(let album):
            MultiSelectRow(item: PlayableMusicItem.album(album), selectedItems: selectedItems)
        case .artist(let artist):
            MultiSelectRow(item: PlayableMusicItem.artist(artist), selectedItems: selectedItems)
        case .playlist(let playlist):
            MultiSelectRow(item: PlayableMusicItem.playlist(playlist), selectedItems: selectedItems)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func topResultCell() -> some View {
        switch self {
        case .album(let album):
            AlbumCell(album)
        case .artist(let artist):
            ArtistCell(artist)
        case .curator(let curator):
            CuratorCell(curator)
        case .musicVideo(let musicVideo):
            TrackCell(.musicVideo(musicVideo))
        case .playlist(let playlist):
            PlaylistCell(playlist)
        case .radioShow(let radioShow):
            RadioShowCell(radioShow)
        case .song(let song):
            TrackCell(.song(song))
        default:
            EmptyView()
        }
    }
}

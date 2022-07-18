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

enum SearchScope: String, CaseIterable {
    case topResults = "Top Results"
    case Artists
    case Albums
    case Playlists
}

struct MusicConfigView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject private var appStorage: AppStorage
    
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var searchText = ""
    @State private var searchScope = SearchScope.topResults
    
    @State private var musicItems: [MusicItemTypeType] = []
    
    @State private var selectedMusicItems: [MusicItemTypeType] = []
    
    
    var filteredMusicItems: [MusicItemTypeType] {
        if searchText.isEmpty {
            return musicItems
        } else {
            return musicManager.searchedArtists.map{$0}
            //            appStorage.songs.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            masterView
            detailView
        }
        //        .onSubmit(of: .search, runSearch)
        //        .onChange(of: searchScope) { _ in runSearch() }
        .onAppear {
            musicItems = musicManager.preloadedMusicItems
            
        }
    }
    
    private var masterView: some View {
        List {
            MusicItemSection(title: "Selected Items", items: MusicItemCollection(selectedMusicItems)) { item in
                MultiSelectRow(item: item, selectedItems: $selectedMusicItems)
            }
            
            if let searchResponse = viewModel.searchResponse {
                MusicItemSection(title: "Recently played", items: searchResponse.topResults) { topResult in
                    topResultCell(for: topResult)
                }
//                ForEach(musicItems) {musicItem in
//                    MultiSelectRow(item: musicItem, selectedItems: $selectedMusicItems)
//                }
            }
        }
        .navigationTitle("Selected Items")
        .searchable(text: $viewModel.searchTerm, scope: $searchScope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue.capitalized)
            }
        }
    }
    
    private var detailView: some View {
        Group {
            if viewModel.searchTerm.isEmpty {
                VStack {
//                    Text("Default View")
//                    Spacer()
                    
                    MusicItemSection(title: "Selected Items", items: MusicItemCollection(musicManager.preloadedMusicItems)) { item in
                        MultiSelectRow(item: item, selectedItems: $selectedMusicItems)
                    }
                    
//                    List (musicItems, id: \.id) { item in
//                        MultiSelectRow(item: item, selectedItems: $selectedMusicItems)
//                    }
                }
            } else {
                itemsList
                    .resignKeyboardOnDragGesture()
            }
        }
    }
    
//    func runSearch() {
//        Task {
//            await musicManager.searchForArtist(searchTerm: searchText)
//        }
//    }
    
    private func startGame() {
        //        startGamePressed = true
        //        Task {
        //            let game = Game(clueSet: await musicManager.setup(), players: players)
        //            appState.currentViewKey = .game(game)
        //        }
    }
    
    @ViewBuilder
    private var itemsList: some View {
        List {
            if let searchResponse = viewModel.searchResponse {
                ForEach(searchResponse.suggestions, id: \.self) { suggestion in
                    Text(suggestion.displayTerm)
                        .onTapGesture {
                            viewModel.searchTerm = suggestion.displayTerm
                        }
                }
                
                MusicItemSection(title: "Top Results", items: searchResponse.topResults) { topResult in
                    topResultCell(for: topResult)
                }
                
            } else {
                Section(header: Text("Personal Recommendations").fontWeight(.semibold)) {
                    ForEach(viewModel.recommendedPlaylists) { playlist in
                        PlaylistCell(playlist)
                    }
                }
            }
        }
        .animation(.default, value: viewModel.recommendedPlaylists)
        .animation(.default, value: viewModel.searchResponse)
    }
    
    @ViewBuilder
    func topResultCell(for topResult: MusicCatalogSearchResponse.TopResult) -> some View {
        switch topResult {
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

public enum MusicItemTypeType: MusicItem, Equatable, Hashable, Identifiable, Sendable, Decodable {
    case album(Album)
    case artist(Artist)
    case playlist(Playlist)
    
    public var id: MusicItemID {
        switch self {
        case .album(let album): return album.id
        case .artist(let artist):  return artist.id
        case .playlist(let playlist): return playlist.id
        }
    }
}

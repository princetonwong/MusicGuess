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
    
    @State private var searchScope: SearchScope = .topResults
    
    @State private var musicItems: [PlayableMusicItem] = []
    
    @State private var selectedMusicItems: [PlayableMusicItem] = []
    
    @Environment(\.isSearching) private var isSearching
    
    @State private var destination: DetailDestination?
    
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
                .frame(minHeight: 200)
                
                
            }
        } detail: {
            NavigationStack {
                switch destination {
                case .preloaded: preloadedList
                case .charts: EmptyView()
                case .search: searchDetailList
                case .none: EmptyView()
                }
            }
        }
        .navigationSplitViewColumnWidth(600)
        .onSubmit(of: .search) {viewModel.runSearch(searchScope: searchScope)}
        .onChange(of: searchScope) {scope in viewModel.runSearch(searchScope: scope)}
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
    private var aList: some View {
        List {
            NavigationLink {EmptyView()} label: {Label("Charts", systemImage: "chart.bar.fill")}
            NavigationLink {preloadedList} label: {Label("Preloaded", systemImage: "info.circle.fill")}
            NavigationLink {searchDetailList} label: {Label("Search", systemImage: "magnifyingglass")}
        }
        .navigationTitle("Select Music")
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
    private var searchDetailList: some View {
        List {
            if let searchResponse = viewModel.searchResponse {
                ForEach(searchResponse.suggestions, id: \.self) { suggestion in
                    Text(suggestion.displayTerm)
                        .onTapGesture {
                            viewModel.searchTerm = suggestion.displayTerm
                        }
                }
                
                MusicItemSection(title: "Top Results", items: searchResponse.topResults) { topResult in
                    topResult.topResultCell()
                }
                
            }
        }
        .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .searchScopes($searchScope) {
            ForEach(SearchScope.allCases) { scope in
                Text(scope.rawValue.capitalized).tag(scope)
            }
        }
        .animation(.default, value: viewModel.recommendedPlaylists)
        .animation(.default, value: viewModel.searchResponse)
    }
}

extension MusicCatalogSearchResponse.TopResult {
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




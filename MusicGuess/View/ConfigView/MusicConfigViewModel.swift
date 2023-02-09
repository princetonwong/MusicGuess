//
//  MusicConfigViewModel.swift
//  MusicGuess
//
//  Created by Princeton Wong on 18/7/2022.
//

import Combine
import MusicKit
import SwiftUI

public enum PlayableMusicItem: MusicItem, Equatable, Hashable, Identifiable, Sendable, Decodable {
    
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

class MusicConfigViewModel: ObservableObject {
    
    init() {
        searchTermObserver = $searchTerm
            .sink(receiveValue: requestSearchSuggestions)
        searchScopeObserver = $searchScope
            .sink(receiveValue: { _ in self.requestSearchSuggestions(for: self.searchTerm)})
    }
    
    @Published var searchTerm = ""
    @Published var searchScope: SearchScope = .topResults
    @Published var searchSuggestionsResponse: MusicCatalogSearchSuggestionsResponse?
//    @Published var searchResponse: MusicCatalogSearchResponse?
    @Published var searchResponse = SearchResponse()
    @Published var recommendedPlaylists: MusicItemCollection<Playlist> = []
    @Published var isDisplayingSuggestedPlaylists = false
    
    private var suggestedPlaylistsObserver: AnyCancellable?
    private var searchTermObserver: AnyCancellable?
    private var searchScopeObserver: AnyCancellable?
    
    struct SearchResponse {
        var albums: MusicItemCollection<Album> = []
        var playlists: MusicItemCollection<Playlist> = []
        var artists: MusicItemCollection<Artist> = []
        var topResults: MusicItemCollection<MusicCatalogSearchResponse.TopResult> = []
    }
    
    
    /// Updates the recently viewed playlists when the MusicKit authorization status changes.
    func loadRecommendedPlaylists() {
        Task {
            do {
                let playlistsRequest = MusicPersonalRecommendationsRequest()
                let playlistsResponse = try await playlistsRequest.response()
                await self.updatedRecommendedPlaylists(playlistsResponse.recommendations.first?.playlists)
            } catch {
                print("Failed to load recommended playlists due to error: \(error)")
            }
        }
    }
    
    
    func produceCategoryWithArtistTopSongs(from artist: Artist) async -> Category? {
        do {
            let detailedArtist = try await artist.with([.topSongs])
            guard let topSongs = detailedArtist.topSongs else { return nil }
            let guesses = topSongs.enumerated().compactMap {
                $0 < 8 ? APGuess(title: $1.title, song: $1, pointValue: APGuess.pointValues[$0]) : nil
            }
            return Category(title: detailedArtist.name, clues: guesses)
        } catch {
            print("Search request failed with error: \(error).")
        }
        return nil
            
    }
    
    func produceCategoryWithPlaylist(from playlist: Playlist) async -> Category? {
        do {
            let detailedPlaylist = try await playlist.with([.tracks])
            guard let tracks = detailedPlaylist.tracks else { return nil }
            var guesses: [APGuess] = tracks.enumerated().shuffled().compactMap {
                if case let .song(songg) = $1, $0 < 8 {
                    return APGuess(title: songg.title, song: songg, pointValue: APGuess.pointValues[$0])
                }
                return nil
            }
            guesses.indices.forEach{
                guesses[$0].pointValue = APGuess.pointValues[$0]
            }
            return Category(title: detailedPlaylist.name, clues: guesses)
        } catch {
            print("Failed to load additional content for \(playlist) with error: \(error).")
        }
        return nil
    }
    
    func produceCategoryWithAlbum(from album: Album) async -> Category? {
        do {
            let detailedAlbum = try await album.with([.tracks])
            guard let tracks = detailedAlbum.tracks else { return nil }
            var guesses: [APGuess] = tracks.enumerated().shuffled().compactMap {
                if case let .song(songg) = $1, $0 < 8 {
                    return APGuess(title: songg.title, song: songg, pointValue: APGuess.pointValues[$0])
                }
                return nil
            }
            guesses.indices.forEach{
                guesses[$0].pointValue = APGuess.pointValues[$0]
            }
            return Category(title: detailedAlbum.title, clues: guesses)
        } catch {
            print("Failed to load additional content for \(album) with error: \(error).")
        }
        return nil
    }
    
    private func requestSearchSuggestions(for searchTerm: String) {
        if searchTerm.isEmpty {
            isDisplayingSuggestedPlaylists = true
            searchSuggestionsResponse = nil
        } else {
            Task {
                var u = [any MusicCatalogSearchable.Type]()
                switch searchScope{
                case .topResults: u = [Album.self, Playlist.self, Artist.self]
                case .Albums: u = [Album.self]
                case .Artists: u = [Artist.self]
                case .Playlists: u = [Playlist.self]
                }
                var searchSuggestionRequest = MusicCatalogSearchSuggestionsRequest(
                    term: searchTerm,
                    includingTopResultsOfTypes: u //[Album.self, Playlist.self, Artist.self]
                )
                do {
                    searchSuggestionRequest.limit = 10
                    let searchSuggestionResponse = try await searchSuggestionRequest.response()
                    await self.update(with: searchSuggestionResponse, for: searchTerm)
                } catch {
                    print("Failed to fetch search suggestions due to error: \(error)")
                }
            }
        }
    }
    
    func requestSearchCatalog(for searchTerm: String) {
        Task {
            var u: [[any MusicCatalogSearchable.Type]] = [[Album.self], [Playlist.self], [Artist.self]]
            
                do {
                    for i in u {
                        var searchRequest = MusicCatalogSearchRequest(
                            term: searchTerm,
                            types: i //[Album.self, Playlist.self, Artist.self]
                        )
                        searchRequest.includeTopResults = true
                        searchRequest.limit = 25
                        let searchResponse = try await searchRequest.response()
                        await self.update(with: searchResponse, for: searchTerm)
                    }
                    var searchRequest = MusicCatalogSearchRequest(
                        term: searchTerm,
                        types: [Album.self, Playlist.self, Artist.self]
                    )
                    searchRequest.includeTopResults = true
                    searchRequest.limit = 25
                    let searchResponse = try await searchRequest.response()
                    print(searchResponse)
                    await self.update(with: searchResponse, for: searchTerm)
                } catch {
                    print("Failed to fetch search suggestions due to error: \(error)")
                }
                
            
        }
    }
    
    @MainActor
    private func updatedRecommendedPlaylists(_ playlists: MusicItemCollection<Playlist>?) {
        recommendedPlaylists = playlists ?? []
    }
    
    @MainActor
    func update(with searchSuggestions: MusicCatalogSearchSuggestionsResponse, for searchTerm: String) {
        if self.searchTerm == searchTerm {
            self.searchSuggestionsResponse = searchSuggestions
        }
    }
    
    @MainActor
    func update(with search: MusicCatalogSearchResponse, for searchTerm: String) {
        self.searchResponse.topResults = search.topResults
        if self.searchTerm == searchTerm {
            if !search.albums.isEmpty {
                self.searchResponse.albums = search.albums
            }
            if !search.playlists.isEmpty {
                self.searchResponse.playlists = search.playlists
            }
            if !search.artists.isEmpty {
                self.searchResponse.artists = search.artists
            }
        }
    }
}

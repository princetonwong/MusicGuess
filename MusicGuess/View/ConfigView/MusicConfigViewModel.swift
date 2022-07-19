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
    }
    
    @Published var searchTerm = ""
    @Published var searchResponse: MusicCatalogSearchSuggestionsResponse?
    @Published var recommendedPlaylists: MusicItemCollection<Playlist> = []
    @Published var isDisplayingSuggestedPlaylists = false
    
    private var suggestedPlaylistsObserver: AnyCancellable?
    private var searchTermObserver: AnyCancellable?
    
    @Environment(\.isSearching) private var isSearching
    
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
            let guesses: [APGuess] = tracks.enumerated().compactMap {
                if case let .song(songg) = $1, $0 < 8 {
                    return APGuess(title: songg.title, song: songg, pointValue: APGuess.pointValues[$0])
                }
                return nil
            }
            return Category(title: detailedPlaylist.name, clues: guesses)
        } catch {
            print("Failed to load additional content for \(playlist) with error: \(error).")
        }
        return nil
    }
    
    func produceCategoryWithAlbum(from album: Album) async -> Category? {
        return nil
    }
    
    private func requestSearchSuggestions(for searchTerm: String) {
        if searchTerm.isEmpty {
            isDisplayingSuggestedPlaylists = true
            searchResponse = nil
        } else {
            Task {
                let searchSuggestionRequest = MusicCatalogSearchSuggestionsRequest(
                    term: searchTerm,
                    includingTopResultsOfTypes: [Album.self, Playlist.self, Artist.self]
                )
                do {
                    let searchSuggestionResponse = try await searchSuggestionRequest.response()
                    await self.update(with: searchSuggestionResponse, for: searchTerm)
                } catch {
                    print("Failed to fetch search suggestions due to error: \(error)")
                }
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
            self.searchResponse = searchSuggestions
        }
    }
}

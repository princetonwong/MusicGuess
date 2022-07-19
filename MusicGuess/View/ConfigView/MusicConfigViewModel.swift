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
    
    func runSearch(searchScope: SearchScope) {
        Task {
            do {
                
                var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Artist.self])
                searchRequest.limit = 10
                let searchResponse = try await searchRequest.response()
                
                if let firstArtist = searchResponse.artists.first {
                    
                    let detailedArtist = try await firstArtist.with([.topSongs])
                    
                    //                    await addArtists(detailedArtist)
                    //
                    //                    if let topSongs = detailedArtist.topSongs {
                    //                        var guesses: [APGuess] = []
                    //                        for (index, song) in topSongs.enumerated() {
                    //                            if index < 8 {
                    //                                let guess = APGuess(title: song.title, song: song, pointValue: APGuess.pointValues[index])
                    //                                guesses.append(guess)
                    //                            }
                    //                        }
                    //
                    //                        let category = Category(title: detailedArtist.name, clues: guesses)
                    //                        return category
                }
            } catch {
                print("Search request failed with error: \(error).")
            }
        }
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

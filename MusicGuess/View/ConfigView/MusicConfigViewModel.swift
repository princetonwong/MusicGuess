//
//  MusicConfigViewModel.swift
//  MusicGuess
//
//  Created by Princeton Wong on 18/7/2022.
//

import Combine
import MusicKit
import SwiftUI

class MusicConfigViewModel: ObservableObject {
    
    // MARK: - Initialization
    
    init() {
        searchTermObserver = $searchTerm
            .sink(receiveValue: requestSearchSuggestions)
    }
    
    // MARK: - Properties
    
    @Published var searchTerm = ""
    @Published var searchResponse: MusicCatalogSearchSuggestionsResponse?
    @Published var recommendedPlaylists: MusicItemCollection<Playlist> = []
    @Published var isDisplayingSuggestedPlaylists = false
    
    private var suggestedPlaylistsObserver: AnyCancellable?
    private var searchTermObserver: AnyCancellable?
    
    // MARK: - Methods
    
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

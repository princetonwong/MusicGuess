//
//  MusicManager.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import Combine
import MusicKit
import Foundation

final class MusicManager: ObservableObject {
    
    static let shared = MusicManager()
    
    /// The key of the currently rendered view.
    @Published var preloadedMusicItems: [MusicItemTypeType] = []
    
    let artistNamesString =
"""
衛蘭
林家謙
許廷鏗
容祖兒
張敬軒
陳奕迅
"""
    var artistTopSongs: [MusicItemCollection<Song>?] = []
    
    var categories: [Category] = []
    
    @MainActor
    func preloadsampleData() async -> ClueSet {
        for name in artistNamesString.lines {
            let newCategory = await requestArtistTopSongs(artistName: name)
            if let newCategory {
                categories.append(newCategory)
            }
        }
        return ClueSet(roundCategories: categories)
    }
    
    @Published var searchedArtists: [MusicItemTypeType] = []
    
//    func searchForArtist(searchTerm: String) async {
//        do {
//            var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Artist.self])
//            searchRequest.limit = 20
//            let searchResponse = try await searchRequest.response()
//            await updateSearchArtists(from: searchResponse)
//        } catch {
//            print("Search request failed with error: \(error).")
//        }
//    }
//    
//    @MainActor
//    private func updateSearchArtists(from searchResponse: MusicCatalogSearchResponse) {
//        searchedArtists = searchResponse.artists
//    }
    
    @MainActor
    private func addArtists(_ artist: Artist) {
        preloadedMusicItems.append(MusicItemTypeType.artist(artist))
    }
    
    func requestArtistTopSongs(artistName: String) async -> Category? {
        do {
            var searchRequest = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
            searchRequest.limit = 1
            let searchResponse = try await searchRequest.response()
            
            if let firstArtist = searchResponse.artists.first {
                
                let detailedArtist = try await firstArtist.with([.topSongs])
                
                await addArtists(detailedArtist)
                
                if let topSongs = detailedArtist.topSongs {
                    var guesses: [APGuess] = []
                    for (index, song) in topSongs.enumerated() {
                        if index < 8 {
                            let guess = APGuess(title: song.title, song: song, pointValue: APGuess.pointValues[index])
                            guesses.append(guess)
                        }
                    }
        
                    let category = Category(title: detailedArtist.name, clues: guesses)
                    return category
                }
            }
        } catch {
            print("Search request failed with error: \(error).")
        }
        return nil
    }
}


fileprivate extension String {
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

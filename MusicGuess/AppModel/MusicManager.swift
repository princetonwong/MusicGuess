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
    @Published var artists: [Artist] = []
    
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
    func setup() async -> ClueSet{
        for name in artistNamesString.lines {
            let newCategory = await requestArtistTopSongs(artistName: name)
            if let newCategory {
                categories.append(newCategory)
            }
        }
        return ClueSet(roundCategories: categories)
    }
    
    func requestArtistTopSongs(artistName: String) async -> Category? {
        do {
            var searchRequest = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
            searchRequest.limit = 1
            let searchResponse = try await searchRequest.response()
            
            if let firstArtist = searchResponse.artists.first {
                
                let detailedArtist = try await firstArtist.with([.topSongs])
                
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

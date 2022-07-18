//
//  AppStorage.swift
//  MusicGuess
//
//  Created by Princeton Wong on 15/7/2022.
//

import Combine
import Foundation
import MusicKit
import Defaults


class AppStorage: ObservableObject {
    
    static let shared = AppStorage()

    @Published var recentlyViewedAlbums: MusicItemCollection<Album> = []
    private var musicAuthorizationStatusObserver: AnyCancellable?
    private let maximumNumberOfRecentlyViewedAlbums = 10
    
    @Published var clueSet: ClueSet?
    
    var songs: [Song] {
        if let clueSet {
            return clueSet.roundCategories.map{$0.clues}.flatMap{$0}.map{$0.song}
        }
        return []
    }
    
    var recentPlayers: [Player] {
        get {
            return  Defaults[.players].compactMap{Player(name: $0)}
        }
        set {
            Defaults[.players] = newValue.map{$0.name}
        }
    }
    
    private var recentlyViewedAlbumIDs: [MusicItemID] {
        get {
            let recentlyViewedAlbumIDs = Defaults[.recentlyViewedAlbumIdentifiers].compactMap { identifier -> MusicItemID? in
                var itemID: MusicItemID?
                itemID = MusicItemID(identifier)
                return itemID
            }
            return recentlyViewedAlbumIDs
        }
        set {
            Defaults[.recentlyViewedAlbumIdentifiers] = newValue.map{$0.rawValue}
            loadRecentlyViewedAlbums()
        }
    }
    
    // MARK: - Methods
    
    func beginObservingMusicAuthorizationStatus() {
        musicAuthorizationStatusObserver = WelcomeView.PresentationCoordinator.shared.$musicAuthorizationStatus
            .filter { authorizationStatus in
                return (authorizationStatus == .authorized)
            }
            .sink { [weak self] _ in
                self?.loadRecentlyViewedAlbums()
            }
    }
    
    func reset() {
        self.recentlyViewedAlbumIDs = []
    }
    
    func update(with recentlyViewedAlbum: Album) {
        var recentlyViewedAlbumIDs = self.recentlyViewedAlbumIDs
        if let index = recentlyViewedAlbumIDs.firstIndex(of: recentlyViewedAlbum.id) {
            recentlyViewedAlbumIDs.remove(at: index)
        }
        recentlyViewedAlbumIDs.insert(recentlyViewedAlbum.id, at: 0)
        while recentlyViewedAlbumIDs.count > maximumNumberOfRecentlyViewedAlbums {
            recentlyViewedAlbumIDs.removeLast()
        }
        self.recentlyViewedAlbumIDs = recentlyViewedAlbumIDs
    }
    
    /// Updates the recently viewed albums when MusicKit authorization status changes.
    private func loadRecentlyViewedAlbums() {
        let recentlyViewedAlbumIDs = self.recentlyViewedAlbumIDs
        if recentlyViewedAlbumIDs.isEmpty {
            self.recentlyViewedAlbums = []
        } else {
            Task {
                do {
                    let albumsRequest = MusicCatalogResourceRequest<Album>(matching: \.id, memberOf: recentlyViewedAlbumIDs)
                    let albumsResponse = try await albumsRequest.response()
                    await self.updateRecentlyViewedAlbums(albumsResponse.items)
                } catch {
                    print("Failed to load albums for recently viewed album IDs: \(recentlyViewedAlbumIDs)")
                }
            }
        }
        
    }
    
    /// Safely changes `recentlyViewedAlbums` on the main thread.
    @MainActor
    private func updateRecentlyViewedAlbums(_ recentlyViewedAlbums: MusicItemCollection<Album>) {
        self.recentlyViewedAlbums = recentlyViewedAlbums
    }
}

extension Defaults.Keys {
    static let recentlyViewedAlbumIdentifiers = Key<[String]>("recently-viewed-albums-identifiers", default: [])
    static let players = Key<[String]>("players", default: [])
}

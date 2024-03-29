//
//  MultiSelectRow.swift
//  MusicGuess
//
//  Created by Princeton Wong on 18/7/2022.
//

import SwiftUI
import MusicKit

struct MultiSelectRow: View {
    
    let item: PlayableMusicItem
    
    @Binding var selectedItems: [PlayableMusicItem]
    
    var isSelected: Bool {
        selectedItems.contains{$0.id == item.id}
    }
    
    var body: some View {
        HStack {
            item.getMusicItemCell()
            
            Spacer()

            if self.isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.blue)
            }
        }
        .onTapGesture {
            if self.isSelected {
                if let index = selectedItems.firstIndex(where: {$0.id == item.id}) {
                    selectedItems.remove(at: index)
                }
            }else {
                selectedItems.insert(item, at: 0)
            }
        }
    }
}

extension PlayableMusicItem {
    @ViewBuilder
    func getMusicItemCell() -> some View {
        switch self {
        case .album(let album):
            AlbumCell(album)
        case .artist(let artist):
            ArtistCell(artist)
        case .playlist(let playlist):
            PlaylistCell(playlist)
        }
    }
}

struct ResultCell: View {
    var song: Song
    
    var body: some View {
        AsyncImage(url: song.artwork?.url(width: 600, height: 600)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Text(song.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
        .cornerRadius(8)
    }
}


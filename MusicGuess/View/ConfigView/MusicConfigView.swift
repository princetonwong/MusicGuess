//
//  MusicConfigView.swift
//  MusicGuess
//
//  Created by Princeton Wong on 16/7/2022.
//

import SwiftUI
import ASCollectionView
import MusicKit

struct MusicConfigView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject private var appStorage: AppStorage
    
    var data: [Song] {
        if let clueSet = appStorage.clueSet {
            let v = clueSet.roundCategories.map{$0.clues}.flatMap{$0}.map{$0.song}
            return v
        }
        return []
    }
    
    var body: some View {
        ASCollectionView(data: data, dataID: \.self) { song, _ in
            Color.blue
                .overlay(Text(song.title))
        }
        .layout{
            .grid(
                layoutMode: .adaptive(withMinItemSize: 100),
                itemSpacing: 5,
                lineSpacing: 5,
                itemSize: .absolute(50))
        }
        .onAppear {
            Task {
                appStorage.clueSet = await musicManager.setup()
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        //        Text("Hello")
    }
    
    
    private func startGame() {
        //        startGamePressed = true
        //        Task {
        //            let game = Game(clueSet: await musicManager.setup(), players: players)
        //            appState.currentViewKey = .game(game)
        //        }
    }
}

struct MusicConfigView_Previews: PreviewProvider {
    static var previews: some View {
        MusicConfigView()
    }
}

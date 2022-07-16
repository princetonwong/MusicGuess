//
//  MusicConfigView.swift
//  MusicGuess
//
//  Created by Princeton Wong on 16/7/2022.
//

import SwiftUI

struct MusicConfigView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var musicManager: MusicManager
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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

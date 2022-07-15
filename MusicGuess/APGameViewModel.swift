//
//  APGameViewModel.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI
import MusicKit

/// A view model that binds a view to a *Jeopardy!* game.
final class APGameViewModel: ObservableObject {
    
    @Published var game: Game
    
    init(game: Game) {
        self.game = game
    }
    
    var currentLeaders: [Player] {
        game.currentLeaders
    }

    var roundCategories: [Category] {
        game.roundCategories
    }
    
    var players: [Player] {
        game.players
    }
    
    var selectedClue: APGuess? {
        game.selectedClue
    }
    
    func markSelectedClueAsDone() {
        game.markSelectedClueAsDone()
    }
    
    func respondToSelectedClue(
        for player: Player,
        correct responseIsCorrect: Bool
    ) {
        game.respondToSelectedClue(for: player, correct: responseIsCorrect)
    }
    
    func selectClue(_ clue: APGuess) {
        game.selectClue(clue)
    }

    func setScore(to newScore: Int, for player: Player) {
        game.setScore(to: newScore, for: player)
    }
}

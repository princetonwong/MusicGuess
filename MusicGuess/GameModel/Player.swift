//
//  Player.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//
import Foundation

struct Player: Codable, Identifiable, Equatable {
    
    var id = "PLAYER-\(UUID())"
    
    let name: String
    var score: Int
    var canSelectClue: Bool = false
    var canRespondToCurrentClue: Bool = false
    
    init(name: String, score: Int = 0) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.score = score
    }
}


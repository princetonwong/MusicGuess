//
//  Game.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//
struct Game: Codable {
    
    // -------------------------------------------------------------------------
    // MARK:- Stored properties
    // -------------------------------------------------------------------------
    private(set) var roundCategories: [Category]
    private(set) var players: [Player]
    private(set) var selectedClue: APGuess?
    
    // -------------------------------------------------------------------------
    // MARK:- Computed property
    // -------------------------------------------------------------------------
    var currentLeaders: [Player] {
        var leaders = [Player]()
        for player in players {
            if player.score > 0 {
                if let leader = leaders.first {
                    if player.score > leader.score {
                        leaders = [player]
                    }
                    else if player.score == leader.score {
                        leaders.append(player)
                    }
                }
                else {
                    leaders = [player]
                }
            }
        }
        return leaders
    }
    
    init(clueSet: ClueSet, players: [Player]) {
        
        self.roundCategories = clueSet.roundCategories
        self.players = players
        let startingPlayerIndex = Int.random(in: self.players.indices)
        for index in players.indices {
            self.players[index].canSelectClue = (index == startingPlayerIndex)
        }
    }
    
    /// Marks the selected clue as “done.”
    ///
    /// If there is currently no selected clue, or this game is currently in the
    /// Final Jeopardy! round, then this method will do nothing.
    ///
    /// Finally, if all categories are finished, then the game will move to the
    /// Final Jeopardy! round.
    mutating func markSelectedClueAsDone() {
        guard let selectedClue = self.selectedClue else {
            return
        }
        self.selectedClue = nil
        for categoryIndex in roundCategories.indices {
            let clues = roundCategories[categoryIndex].clues
            if let clueIndex = clues.firstIndex(of: selectedClue) {
                if !clues[clueIndex].isDone {
                    roundCategories[categoryIndex]
                        .clues[clueIndex]
                        .isDone = true
                }
            }
        }
    }

    
    /// Responds to the selected clue.
    ///
    /// If the contestant’s response is correct, then the selected clue’s point
    /// value is added to his/her score, and he/she may select a new clue from
    /// the game board. An incorrect response deducts the amount from his/her
    /// score and allows the other contestants the opportunity to ring in and
    /// respond.
    ///
    /// If the clue is a Daily Double, then the contestant’s wager is added or
    /// subtracted instead depending on his/her response. Whether or not he/she
    /// responds correctly, he/she chooses the next clue.
    ///
    /// If the contestant has already given a response to the clue, then this
    /// method will do nothing.
    ///
    /// - Parameter player:            The contestant who responded to the clue.
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    mutating func respondToSelectedClue(
        for player: Player,
        correct responseIsCorrect: Bool
    ) {
        if !player.canRespondToCurrentClue {
            return
        }
        if let playerIndex = players.firstIndex(of: player) {
            if let clue = selectedClue {
                ruleResponse(
                    for: player,
                    amount: clue.pointValue,
                    correct: responseIsCorrect
                )
                if responseIsCorrect {
                    for index in players.indices {
                        players[index].canSelectClue = (index == playerIndex)
                        players[index].canRespondToCurrentClue = false
                    }
                }
            }
        }
    }
    
    /// Selects the specified clue.
    ///
    /// Only one clue on the game board may be selected at a time. If the
    /// selected clue is already marked as “done,” or this game is currently in
    /// the Final Jeopardy! round, then this method will do nothing.
    ///
    /// - Parameter clue: The clue to be selected.
    mutating func selectClue(_ clue: APGuess) {
        if clue.isDone {
            return
        }
        selectedClue = clue
        for playerIndex in players.indices {
            players[playerIndex].canRespondToCurrentClue = true
        }
    }
    
    mutating func setScore(to newScore: Int, for player: Player) {
        if let playerIndex = players.firstIndex(of: player) {
            players[playerIndex].score = newScore
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Private method
    // -------------------------------------------------------------------------
    
    private mutating func ruleResponse(
        for player: Player,
        amount: Int,
        correct responseIsCorrect: Bool
    ) {
        if let playerIndex = players.firstIndex(of: player) {
            let changeInScore = responseIsCorrect ? +amount : -amount
            players[playerIndex].score = player.score + changeInScore
            players[playerIndex].canRespondToCurrentClue = false
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Type properties
    // -------------------------------------------------------------------------
    
    /// The number of categories in the Jeopardy! round.
    static let categoryCount = 6
    
    /// The number of clues in each category.
    static let clueCountPerCategory = 5
    
    /// The highest clue value available in the Jeopardy! round.
    static let maximumCluePointValue = 1000
}


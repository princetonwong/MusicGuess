//
//  ClueSet.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import Foundation

/// A clue set for a *Jeopardy!* game.
struct ClueSet: Codable {
    
    /// The categories in the Jeopardy! round.
    var roundCategories: [Category]
    
    private func validateCategory(at index: Int) throws {
        
        let category = roundCategories[index]
        
        if category.title.isEmpty {
            throw ValidationError.emptyCategoryTitle(categoryIndex: index)
        }
        
        let clueCount = category.clues.count
        if clueCount != Game.clueCountPerCategory {
            throw ValidationError.incorrectClueCount(
                clueCount,
                categoryIndex: index
            )
        }
        
        for clueIndex in category.clues.indices {
            try validateClue(at: clueIndex, categoryIndex: index)
        }
    }

    private func validateClue(at clueIndex: Int, categoryIndex: Int) throws {
        
        let clue = roundCategories[categoryIndex].clues[clueIndex]
        let expectedPointValue = (clueIndex + 1) * 200
        
        if clue.pointValue != expectedPointValue {
            throw ValidationError.incorrectPointValue(
                clue.pointValue,
                expectedPointValue: expectedPointValue,
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
//        if clue.answer.isEmpty {
//            throw ValidationError.emptyAnswer(
//                categoryIndex: categoryIndex,
//                clueIndex: clueIndex
//            )
//        }
//        if clue.correctResponse.isEmpty {
//            throw ValidationError.emptyCorrectResponse(
//                categoryIndex: categoryIndex,
//                clueIndex: clueIndex
//            )
//        }
//        if let image = clue.image, image.isEmpty {
//            throw ValidationError.emptyImage(
//                categoryIndex: categoryIndex,
//                clueIndex: clueIndex
//            )
//        }
        if clue.isDone {
            throw ValidationError.clueIsDone(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
    }
    
    /// Validates this clue set.
    private func validateClueSet() throws {
        
        let categoryCount = roundCategories.count
        if categoryCount != Game.categoryCount {
            throw ValidationError.incorrectCategoryCount(categoryCount)
        }
        for index in roundCategories.indices {
            try validateCategory(at: index)
        }
    }
    
    
    /// A validation error.
    enum ValidationError: Error {
        
        /// An error that denotes an incorrect number of categories.
        case incorrectCategoryCount(Int)
        
        /// An error that denotes an empty category title.
        case emptyCategoryTitle(categoryIndex: Int)
        
        /// An error that denotes an incorrect number of clues in a category.
        case incorrectClueCount(Int, categoryIndex: Int)
        
        /// An error that denotes an incorrect point value.
        case incorrectPointValue(
            Int,
            expectedPointValue: Int,
            categoryIndex: Int,
            clueIndex: Int
        )
        
        /// An error that denotes an empty “answer.”
        case emptyAnswer(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes an empty correct response.
        case emptyCorrectResponse(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes an empty image filename.
        case emptyImage(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes a clue already marked as “done.”
        case clueIsDone(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes an incorrect number of Daily Doubles.
        case incorrectDailyDoubleCount(Int)
    }
}

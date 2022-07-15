//
//  APBoardView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

struct APBoardView: View {
    
    @ObservedObject var viewModel: APGameViewModel
    
    private let gridItemSpacing: CGFloat = 8
    
    var body: some View {
        HStack(spacing: gridItemSpacing) {
            ForEach(viewModel.roundCategories) { category in
                VStack(alignment: .center , spacing: gridItemSpacing) {
                    GameBoardCell {
                        Text(category.isDone ? "" : category.title.uppercased())
                            .font(.custom("Impact", size: 28))
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                            .multilineTextAlignment(.center)
                    }
                    ForEach(category.clues) { clue in
                        GameBoardCell {
                            Text(clue.isDone ? "" : String(clue.pointValue))
                                .font(.custom("Impact", size: 64))
                                .minimumScaleFactor(0.75)
                                .foregroundColor(.trebekGold)
                                .shadow(color: .black, radius: 0, x: 4, y: 4)
                        }
                        .onTapGesture {
                            if !clue.isDone {
                                self.viewModel.selectClue(clue)
                            }
                        }
                    }
                }
            }
        }
        .scaledToGameBoard()
    }
}

/// A cell in the game board grid.
fileprivate struct GameBoardCell<Content>: View where Content: View {
    
    /// The content that is presented in this cell.
    let content: () -> Content
    
    var body: some View {
        content()
            .padding(8)
            .frame(maxWidth: .infinity, minHeight: 64, maxHeight: .infinity)
            .background(Color.trebekBlue)
    }
}


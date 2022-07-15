//
//  GameView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

struct APGameView: View {
    @ObservedObject var viewModel: APGameViewModel
    
    @State private var leaderboardIsVisible = false
    
    @State private var errorAlertInfo: ErrorAlertItem?
    
    var body: some View {
        ZStack {
            HStack {
                
                /// Left side of the window
                Group {
//                    Image("jeopardy-logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 100)
//                        .padding()
                    if let clue = viewModel.selectedClue {
                        ClueView(clue: clue) {
                            self.viewModel.markSelectedClueAsDone()
                        }
                    }
                    else {
                        APBoardView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing, .bottom])
                
                /// Right side of the window
                VStack {
                    Button("VIEW LEADERBOARD") {
                        self.leaderboardIsVisible = true
                    }
                    .buttonStyle(TrebekButtonStyle())
                    .padding()
                    Divider()
                    ScrollView(.vertical) {
                        ForEach(viewModel.players) {
                            PlayerCellView(
                                player: $0,
                                viewModel: viewModel,
                                errorAlertInfo: $errorAlertInfo
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: 300)
                .frame(maxHeight: .infinity)
                .background(Color("Player List Panel Background"))
            }
            .alert(item: $errorAlertInfo) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
            
            if leaderboardIsVisible {
                LeaderboardView(players: viewModel.players) {
                    self.leaderboardIsVisible = false
                }
            }
        }
    }
}

//
//  LeaderboardView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

/// A view that displays the leaderboard for a *Jeopardy!* game.
struct LeaderboardView: View {
    
    /// The contestants in the *Jeopardy!* game.
    let players: [Player]
    
    /// The action to perform when the “Back to Game” button is clicked on.
    let onExit: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("LEADERBOARD").font(.custom("PT Sans Bold", size: 96))
                Spacer()
                Button("BACK TO GAME", action: onExit)
                    .buttonStyle(TrebekButtonStyle())
            }
            ScrollView(.vertical) {
                ForEach(players.sorted { $0.score > $1.score }) { player in
                    HStack {
                        Text(player.name.uppercased())
                        Spacer()
                        Text("\(player.score)")
                    }
                        .padding(.vertical, 16)
                }
            }
                .font(.custom("PT Sans", size: 64))
        }
            .padding(48)
            .background(BackgroundView())
    }
}

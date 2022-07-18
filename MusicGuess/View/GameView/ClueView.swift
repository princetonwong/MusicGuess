//
//  SwiftUIView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI
import MusicKit

struct ClueView: View {
    let clue: APGuess
    
    let onExit: () -> Void
    
    @State private var showsAnswer = false
    
    private let player = ApplicationMusicPlayer.shared
    
    var body: some View {
        if !showsAnswer {
            GamePlayView(clue: clue)
                .onTapGesture {
                    self.showsAnswer = true
                }
        }
        else {
            GamePlayAnswerView(clue: clue)
                .onTapGesture {
                    onExit()
                    player.pause()
                }
        }
    }
}



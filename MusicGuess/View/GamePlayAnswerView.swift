//
//  GamePlayAnswerView.swift
//  MusicGuess
//
//  Created by Princeton Wong on 15/7/2022.
//

import SwiftUI
import MusicKit

struct GamePlayAnswerView: View {
    
    let clue: APGuess
    
    var body: some View {
        HStack {
            if let artwork = clue.song.artwork {
                ArtworkImage(artwork, width: 400)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            VStack {
                Text(clue.song.title)
                    .font(.largeTitle)
                Text(clue.song.artistName)
                    .font(.title)
            }
            .bold()
            .foregroundColor(Color(clue.song.customBackGroundColor))
            
            
            Spacer()
        }
        .modifier(BlueSlide(backgroundColor: clue.song.customTextColor))
    }
}

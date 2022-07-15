//
//  BlueSlide.swift
//  MusicGuess
//
//  Created by Princeton Wong on 15/7/2022.
//

import SwiftUI

struct BlueSlide: ViewModifier {
    var backgroundColor: CGColor = .trebekBlue
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 40)
            .padding(.horizontal, 80)
            .aspectRatio(1.7778, contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(backgroundColor))
            .scaledToGameBoard()
    }
}

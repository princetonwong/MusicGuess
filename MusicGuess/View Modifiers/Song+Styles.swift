//
//  Song+Styles.swift
//  MusicGuess
//
//  Created by Princeton Wong on 15/7/2022.
//

import MusicKit
import SwiftUI

extension Song {
    var customTextColor: CGColor {
        self.artwork?.primaryTextColor ?? CGColor.trebekGold
    }
    
    var customBackGroundColor: CGColor {
        self.artwork?.backgroundColor ?? CGColor.trebekBlue
    }
}

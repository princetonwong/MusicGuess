//
//  Category.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import Foundation
import MusicKit


struct Category: Codable, Identifiable {
    
    var id = "CATEGORY-\(UUID())"

    let title: String
    var clues: [APGuess] = []
    var isDone: Bool {
        clues.allSatisfy { $0.isDone }
    }
    
}


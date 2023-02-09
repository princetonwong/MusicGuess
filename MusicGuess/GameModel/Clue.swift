//
//  Clue.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import Foundation
import MusicKit
import SwiftUI

//struct Clue: Codable, Identifiable, Equatable {
//    
//    var id = "CLUE-\(UUID())"
//    
//    let pointValue: Int
//    let answer: String
//    let correctResponse: String
//    let image: String?
//    var isDone: Bool = false
//    
//    init(
//        pointValue: Int,
//        answer: String,
//        correctResponse: String,
//        image: String? = nil
//    ) {
//        self.pointValue = pointValue
//        self.answer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
//        self.correctResponse = correctResponse.trimmingCharacters(in: .whitespacesAndNewlines)
//        self.image = image?.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}

struct APGuess: Codable, Identifiable, Equatable {
    static var pointValues = [1,2,4,6,8,12,16,20]
    
    var id = "APSONG-\(UUID())"
    
    let title: String
    let song: Song
    
    var isDone: Bool = false
    var pointValue: Int
}

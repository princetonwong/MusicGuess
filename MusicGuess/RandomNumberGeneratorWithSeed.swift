//
//  RandomNumberGeneratorWithSeed.swift
//  GuessTheSong
//
//  Created by Princeton Wong on 11/2/2022.
//

import Foundation

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) {
        // Set the random seed
        srand48(seed)
    }
    
    func next() -> UInt64 {
        // drand48() returns a Double, transform to UInt64
        return withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}

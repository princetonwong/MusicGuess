//
//  File.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

/// The global app state.
final class AppState: ObservableObject {
    static let shared = AppState()
    
    /// The key of the currently rendered view.
    @Published var currentViewKey = ViewKey.playerConfig
    
    /// A valid key to render a view.
    enum ViewKey {
        case playerConfig
        case musicConfig([Player])
        case game(Game)

    }
}

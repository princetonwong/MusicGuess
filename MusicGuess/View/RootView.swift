//
//  RootView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//
import SwiftUI

/// The **root view**.
struct RootView: View {
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var musicManager: MusicManager
    @EnvironmentObject private var appStorage: AppStorage
    
    var body: some View {
        currentView
            .scaledToWindow()
            .background(BackgroundView())
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
    }
    
    /// The currently rendered view.
    @ViewBuilder private var currentView: some View {
        switch appState.currentViewKey {
        case .playerConfig:
            PlayerConfigView()
        case .musicConfig:
            MusicConfigView()
        case .game(let game):
            APGameView(viewModel: APGameViewModel(game: game))
        }
    }
}

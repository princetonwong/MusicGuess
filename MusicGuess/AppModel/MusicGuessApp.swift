//
//  MusicGuessApp.swift
//  MusicGuess
//
//  Created by Princeton Wong on 13/7/2022.
//

import MusicKit
import SwiftUI

@main
struct MusicGuessApp: App {
    
    @StateObject private var appState = AppState.shared
    @StateObject private var appStorage = AppStorage.shared
    @StateObject private var musicManager = MusicManager.shared
    
    // MARK: - Object lifecycle
    
//    init() {
//        adjustVisualAppearance()
//    }
    
    // MARK: - App
    
    /// The app’s root view.
    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .frame(minWidth: 400.0, minHeight: 200.0)
            RootView()
                .environmentObject(appState)
                .environmentObject(musicManager)
                .environmentObject(appStorage)
                .onAppear(perform: appStorage.beginObservingMusicAuthorizationStatus)
                .welcomeSheet()
        }
    }
    
    // MARK: - Methods
    
//    / Configures the UI appearance of the app.
//    private func adjustVisualAppearance() {
//        var navigationBarLayoutMargins: UIEdgeInsets = .zero
//        navigationBarLayoutMargins.left = 26.0
//        navigationBarLayoutMargins.right = navigationBarLayoutMargins.left
//        UINavigationBar.appearance().layoutMargins = navigationBarLayoutMargins
//
//        var tableViewLayoutMargins: UIEdgeInsets = .zero
//        tableViewLayoutMargins.left = 28.0
//        tableViewLayoutMargins.right = tableViewLayoutMargins.left
//        UITableView.appearance().layoutMargins = tableViewLayoutMargins
//    }
}

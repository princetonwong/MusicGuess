//
//  GamePlayView.swift
//  GuessTheSong (iOS)
//
//  Created by Princeton Wong on 11/2/2022.
//

import SwiftUI
import MediaPlayer
import GameKit
import MusicKit

struct GamePlayView: View {
    
    // -------------------------------------------------------------------------
    // MARK:- Player State
    // -------------------------------------------------------------------------
    
    private let player = ApplicationMusicPlayer.shared
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    @State private var isPlaybackQueueSet = false
    @State private var currentTimeIntervalIndex = 1
    private var isPlaying: Bool {playerState.playbackStatus == .playing}
    
    private let numberOfIntervals = 4
    private func randomSongIntervals(length: Double = 140.0, from song: Song) -> [TimeInterval] {
        var generatorInUse = RandomNumberGeneratorWithSeed(seed: Int(song.releaseDate?.timeIntervalSince1970 ?? 64))
        let divied = (1...numberOfIntervals).map {length / Double(numberOfIntervals + 1 + 2) * Double($0) }
        let shuuff = divied.shuffled(using: &generatorInUse)
        return shuuff
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Song
    // -------------------------------------------------------------------------
    
    let clue: APGuess
    
    @State private var artwork: Artwork?

    // -------------------------------------------------------------------------
    // MARK:- View
    // -------------------------------------------------------------------------
    
    private let playButtonTitle: LocalizedStringKey = "Play"
    private let pauseButtonTitle: LocalizedStringKey = "Pause"
    private let changeIntervalTitle: LocalizedStringKey = "Change Interval"
    
    var body: some View {
        
        HStack {
            Button(action: handlePlayButtonSelected) {
                HStack {
                    Image(systemName: (isPlaying ? "pause.fill" : "play.fill"))
                    Text((isPlaying ? pauseButtonTitle : playButtonTitle))
                }
            }
            .animation(.easeInOut(duration: 0.1), value: isPlaying)
            
            
            Button(action: handleFastForwardButtonSelected) {
                HStack {
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                    Text(changeIntervalTitle)
                }
            }

        }
//        .buttonStyle(.prominent)
        .buttonStyle(TrebekButtonStyle())
        .modifier(BlueSlide(backgroundColor: clue.song.customBackGroundColor))
        .onAppear {
            player.queue = ApplicationMusicPlayer.Queue(for: [clue.song], startingAt: clue.song)
            prepareToPlay()
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Button functions
    // -------------------------------------------------------------------------
    
    private func handlePlayButtonSelected() {
        
        if !isPlaying {
            if !isPlaybackQueueSet {
                isPlaybackQueueSet = true
                currentTimeIntervalIndex = (0...numberOfIntervals - 1).randomElement()!
                beginPlaying()
                player.playbackTime = randomSongIntervals(from: clue.song)[currentTimeIntervalIndex]
                
            } else {
                beginPlaying()
            }
        }else {
            player.pause()
        }
    }
    
    private func handleFastForwardButtonSelected() {
        currentTimeIntervalIndex += 1
        player.playbackTime = randomSongIntervals(from: clue.song)[currentTimeIntervalIndex % numberOfIntervals]
    }
    
    private func beginPlaying() {
        Task {
            do {
                try await player.play()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
    
    private func prepareToPlay() {
        Task {
            do {
                try await player.prepareToPlay()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
}


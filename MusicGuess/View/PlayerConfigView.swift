//
//  GameConfigView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

struct PlayerConfigView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var musicManager: MusicManager
    
//    @State private var clueSet: ClueSet?
    
    @State private var players = [Player]()
    
    @State private var newPlayerName = ""
    
    /// The info of the error alert that is currently presented onscreen.
//    @State private var errorAlertInfo: ErrorAlertItem?
    
    
    @FocusState private var playerFieldIsFocused: Bool
    @State private var startGamePressed: Bool = false
    
    
    var body: some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            Text("START A NEW GAME")
                .font(.custom("PT Sans Bold", size: 48))
            
            VStack {
                Text("CONTESTANTS")
                    .font(.custom("PT Sans", size: 32))
                    .padding()
                HStack(spacing: 12) {
                    TextField(
                        "Player Name",
                        text: $newPlayerName,
                        onCommit: addNewPlayer
                    )
                    .focused($playerFieldIsFocused)
                    
                    
                    Button(action: addNewPlayer) {
                        Label(
                            title: { Text("ADD") },
                            icon: { Image(systemName: "plus.circle.fill") }
                        )
                    }
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                }
                if players.isEmpty {
                    Text("No contestants added.")
                        .font(.custom("PT Sans", size: 14))
                        .padding(.top)
                }
                else {
                    ScrollView(.vertical) {
                        ForEach(players) { player in
                            HStack {
                                Text(player.name.uppercased())
                                Spacer()
                                removePlayerButton(for: player)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .font(.custom("PT Sans", size: 20))
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                }
            }
            .frame(width: 600)
            
            Spacer(minLength: 0)
            
            Button(!startGamePressed ? "START GAME" : "Loading ...", action: startGame)
            //                .disabled(clueSet == nil || players.count < minimumPlayerCount)
            
            Spacer(minLength: 8)
        }
        .padding(32)
        .buttonStyle(TrebekButtonStyle())
        .textFieldStyle(TrebekTextFieldStyle())
//        .alert(item: $errorAlertInfo) {
//            Alert(title: Text($0.title), message: Text($0.message))
//        }
    }
    
    private func addNewPlayer() {
        playerFieldIsFocused.toggle()
        if newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        players.append(Player(name: newPlayerName))
        newPlayerName = ""
    }
    
    
    private func removePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(of: player) {
            players.remove(at: playerIndex)
        }
    }
    
    private func removePlayerButton(for player: Player) -> some View {
        return Button(action: { self.removePlayer(player) }) {
            Label(
                title: { Text("") },
                icon: { Image(systemName: "xmark.circle.fill") }
            )
        }
        .buttonStyle(TrebekButtonStyle(colorMode: .error))
    }
    
    private func startGame() {
        startGamePressed = true
        Task {
            let game = Game(clueSet: await musicManager.setup(), players: players)
            appState.currentViewKey = .game(game)
        }
    }
}
    
    //    /// Uploads a clue set to the app.
    //    private func uploadClueSet() {
    //        return
    //#if os(macOS)
    //
    //        let openPanel = NSOpenPanel()
    //        openPanel.title = "Upload Clue Set"
    //        openPanel.showsResizeIndicator = true
    //        openPanel.canChooseDirectories = false
    //        openPanel.allowsMultipleSelection = false
    //        openPanel.showsHiddenFiles = false
    //        openPanel.allowedFileTypes = ["json"]
    //
    //        let response = openPanel.runModal()
    //        if response == .OK {
    //            let clueSetURL = openPanel.url!
    //            let clueSetData = try! Data(contentsOf: clueSetURL)
    //            let decoder = JSONDecoder()
    //            do {
    //                let clueSet = try decoder
    //                    .decode(ClueSet.self, from: clueSetData)
    //                self.clueSet = clueSet
    //                self.clueSetFilename = clueSetURL.lastPathComponent
    //            }
    //            catch let validationError as ClueSet.ValidationError {
    //                errorAlertInfo = ErrorAlertItem(
    //                    title: "Invalid Clue Set",
    //                    message: validationError.message
    //                )
    //            }
    //            catch DecodingError.keyNotFound(let codingKey, _) {
    //                errorAlertInfo = ErrorAlertItem(
    //                    title: "Parsing Error",
    //                    message: codingKey.description
    //                )
    //            }
    //            catch DecodingError.dataCorrupted(let context) {
    //                errorAlertInfo = ErrorAlertItem(
    //                    title: "Parsing Error",
    //                    message: context.debugDescription
    //                )
    //            }
    //            catch {
    //            }
    //        }
    //#endif
    //    }
    //}
    //
    //fileprivate extension ClueSet.ValidationError {
    //
    //    /// The error message.
    //    var message: String {
    //        switch self {
    //        case .incorrectCategoryCount(let categoryCount):
    //            return "Incorrect number of categories "
    //            + "(expected: \(Game.categoryCount), "
    //            + "actual: \(categoryCount))"
    //        case .emptyCategoryTitle(let categoryIndex):
    //            return "The title of category \(categoryIndex + 1) is empty."
    //        case .incorrectClueCount(let clueCount, let categoryIndex):
    //            return "Incorrect number of clues in category \(categoryIndex + 1) "
    //            + "(expected: \(Game.clueCountPerCategory), "
    //            + "actual: \(clueCount))"
    //        case .incorrectPointValue(
    //            let actualPointValue,
    //            let expectedPointValue,
    //            let categoryIndex,
    //            let clueIndex
    //        ):
    //            return "Incorrect point value of clue \(clueIndex + 1) in "
    //            + "category \(categoryIndex + 1) "
    //            + "(expected: \(expectedPointValue), "
    //            + "actual: \(actualPointValue))"
    //        case .emptyAnswer(let categoryIndex, let clueIndex):
    //            return "The “answer” of clue \(clueIndex + 1) in "
    //            + "category \(categoryIndex + 1) is empty."
    //        case .emptyCorrectResponse(let categoryIndex, let clueIndex):
    //            return "The correct response to clue \(clueIndex + 1) in "
    //            + "category \(categoryIndex + 1) is empty."
    //        case .emptyImage(let categoryIndex, let clueIndex):
    //            return "The accompanying image filename for clue \(clueIndex + 1) "
    //            + "in category \(categoryIndex + 1) is empty."
    //        case .clueIsDone(let categoryIndex, let clueIndex):
    //            return "Clue \(clueIndex + 1) in category \(categoryIndex + 1) "
    //            + "cannot be marked as “done.”"
    //        case .incorrectDailyDoubleCount(let dailyDoubleCount):
    //            return "Incorrect number of Daily Doubles "
    //            + "(expected: 2, actual: \(dailyDoubleCount))"
    //        }
    //    }
    //}

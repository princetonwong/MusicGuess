//
//  PlayerView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

/// A view that displays a contestant’s name and score.
struct PlayerCellView: View {
    
    let player: Player
    
    @ObservedObject var viewModel: APGameViewModel
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @Binding var errorAlertInfo: ErrorAlertItem?
    
    @State private var editModeIsEnabled = false
    
    @State private var editableScoreText = ""
    @FocusState private var emailFieldIsFocused: Bool
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(player.name).font(.custom("PT Sans", size: 20))
                if editModeIsEnabled {
                    TextField(
                        "Score",
                        text: $editableScoreText,
                        onCommit: changeScore
                    )
                    .textFieldStyle(TrebekTextFieldStyle())
                    .autocorrectionDisabled()
                    .focused($emailFieldIsFocused)
                }
                else {
                    Text("\(player.score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(scoreColor)
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: respondToClue(correct: true)) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(responseButtonsAreDisabled)
                
                Button(action: respondToClue(correct: false)) {
                    Image(systemName: "minus.circle.fill")
                }
                .disabled(responseButtonsAreDisabled)
            
                Button(action: enableEditMode) {
                    Image(systemName: "pencil.circle.fill")
                }
//                .buttonStyle(TrebekButtonStyle())

            }
            .font(.title)
            .frame(minHeight: 16, maxHeight: 30)
            
        }
        .padding()
        .background(backgroundColor)
    }
    
    /// The background color of this view.
    private var backgroundColor: Color {
        return player.canSelectClue ? Color.trebekBlue.opacity(0.5) : .clear
    }
    
    /// Indicates whether the response buttons are disabled.
    private var responseButtonsAreDisabled: Bool {
        return editModeIsEnabled || !player.canRespondToCurrentClue
    }
    
    /// The score color.
    private var scoreColor: Color {
        player.score < 0 ? .red : .primary
    }
    
    /// Change the contestant’s score to the value in the *Score* text field.
    private func changeScore() {
        if let newScore = Int(editableScoreText.trimmingCharacters(in: .whitespacesAndNewlines)) {
            viewModel.setScore(to: newScore, for: player)
            editModeIsEnabled = false
            return
        }
        errorAlertInfo = ErrorAlertItem(
            title: "Invalid Input",
            message: "The value entered is not a valid score. Please try again."
        )
    }
    
    /// Enables “Edit Mode” on this view.
    private func enableEditMode() {
        editableScoreText = String(player.score)
        editModeIsEnabled.toggle()
        emailFieldIsFocused.toggle()
    }
    
    /// Responds to the current clue.
    ///
    /// If the contestant’s response is correct, then the selected clue’s point
    /// value (or his/her Daily Double wager) is added to his/her score. If the
    /// game is currently in the Final Jeopardy! round, then the wager section
    /// will appear above the list of contestants instead.
    ///
    /// An incorrect response deducts that amount from the contestant’s score.
    ///
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    ///
    /// - Returns: The action to perform when ruling the contestant’s response.
    private func respondToClue(
        correct responseIsCorrect: Bool
    ) -> (() -> Void) {
        return {
            self.viewModel.respondToSelectedClue(
                for: player,
                correct: responseIsCorrect
            )
        }
    }
}

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

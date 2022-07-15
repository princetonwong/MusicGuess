//
//  ProminentButtonStyle.swift
//  MusicGuess
//
//  Created by Princeton Wong on 15/7/2022.
//

import SwiftUI

struct ProminentButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundColor(.accentColor)
            .padding()
            .background(backgroundColor.cornerRadius(8))
    }
    
    private var backgroundColor: Color {
        return Color(uiColor: (colorScheme == .dark) ? .secondarySystemBackground : .systemBackground)
    }
}

// MARK: - Button style extension

extension ButtonStyle where Self == ProminentButtonStyle {
    
    static var prominent: ProminentButtonStyle {
        ProminentButtonStyle()
    }
}

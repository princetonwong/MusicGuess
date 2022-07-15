//
//  BackgroundView.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

/// A background view.
struct BackgroundView: View {
    
    /// The color scheme of this view.
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if colorScheme == .dark {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(red: 0.0706, green: 0.0745, blue: 0.098),
                        Color(red: 0.0431, green: 0.1176, blue: 0.2353)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        else {
            Color.white
        }
    }
}

//
//  ControlStyles.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import SwiftUI

/// The font size of the text in the controls.
fileprivate let fontSize: CGFloat = 20

/// The vertical padding in the controls.
fileprivate let verticalPadding: CGFloat = 8


struct TrebekButtonStyle: ButtonStyle {
    
    /// The color mode.
    private let colorMode: ColorMode
    
    /// Creates a button style with the specified color mode.
    ///
    /// - Parameter colorMode: The color mode. The default is `.primary`.
    init(colorMode: ColorMode = .primary) {
        self.colorMode = colorMode
    }
    
    func makeBody(configuration: Configuration) -> some View {
        return ContainerView(colorMode: colorMode, configuration: configuration)
    }
    
    /// A color mode for the button.
    enum ColorMode {
        case primary
        case error
    }
    
    /// A container view that describes the effect of pressing the button.
    private struct ContainerView: View {
        
        /// Indicates whether the button allows user interaction.
        @Environment(\.isEnabled) private var isEnabled
        
        /// The color mode.
        let colorMode: ColorMode
        
        /// The properties of the button.
        let configuration: TrebekButtonStyle.Configuration
        
        var body: some View {
            configuration.label
                .font(.custom("PT Sans Narrow Bold", size: fontSize))
                .foregroundColor(isEnabled ? .black : .white)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, verticalPadding)
                .cornerRadius(verticalPadding)
                .background(backgroundColor)
                .opacity(isEnabled ? 1 : 0.5)
                .animation(.default, value: isEnabled)
        }
        
        /// The background color of the button.
        private var backgroundColor: Color {
            if !isEnabled {
                return .gray
            }
            switch colorMode {
            case .primary:
                return (configuration.isPressed)
                    ? Color(red: 0.8588, green: 0.5373, blue: 0.0157)
                    : .trebekGold
            case .error:
                return (configuration.isPressed)
                    ? Color(red: 0.9882, green: 0.0784, blue: 0.0196)
                    : Color(red: 0.9922, green: 0.3137, blue: 0.2706)
            }
        }
    }
}

struct TrebekTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        return configuration
            .textFieldStyle(PlainTextFieldStyle())
            .cornerRadius(8)
            .font(.custom("PT Sans", size: fontSize))
            .padding(.vertical, verticalPadding)
            .padding(.horizontal)
            .background(Color("Text Field Background"))
    }
}

//
//  Button+Bouncing.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on 19/08/24.
//
import SwiftUI

struct BouncingButtonStyle: ButtonStyle {
    @State private var isPressed = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 20/255, green: 20/255, blue: 20/255)).frame(width: 130)
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.3), value: isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                isPressed = pressed
            }
    }
}

extension Button {
    func bouncingStyle() -> some View {
        self.buttonStyle(BouncingButtonStyle())
    }
}

//
//  ConditionalModifier.swift
//  boringNotch
//
//  Created by Richard Kunkli on 20/08/2024.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

//
//  TabButton.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-24.
//

import SwiftUI

struct TabButton: View {
    let icon: String
    let label: String
    let selected: Bool
    let backgroundColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    let onClick: () -> Void
    init(label: String, icon: String, selected: Bool, onTap: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.selected = selected
        self.onClick = onTap
    }


    var body: some View {
        Button(action: onClick) {
            HStack{
               Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(5)
                    .font(.caption2)
                Text(label)
                    .foregroundColor(.white) // Text color
                    .padding(5)
                    .font(.caption2)
            }
            
            .background(selected ? backgroundColor : Color.clear)
            .padding(10)
            .cornerRadius(15) // Rounded corners
            .frame(width: 130)
        }
        .buttonStyle(PlainButtonStyle())
        
        
        
    }
}

#Preview {
    TabButton(label: "Home", icon: "tray.fill", selected: true) {
        print("Tapped")
    }
}

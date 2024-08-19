//
//  BoringSystemTiles.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on 16/08/24.
//

import Foundation
import SwiftUI


struct SystemItemButton: View {
    
    @State var icon: String = "gear"
    var onTap: () -> Void
    @State var label: String?
    
    var body: some View {
        Button(action: onTap) {
            Text(label!)
                .font(.caption2)
                .fontWeight(.regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
        }
        .buttonStyle(BouncingButtonStyle())
        .frame(width: 130)
    }
}

func logout() {
    DispatchQueue.global(qos: .background).async {
        let appleScript = """
        tell application "System Events" to log out
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}

struct BoringSystemTiles: View {
    var vm: BoringViewModel?
    @ObservedObject var microphoneHandler: MicrophoneHandler
    
    struct ItemButton {
        var icon: String
        var onTap: () -> Void
    }
    
    init(vm: BoringViewModel, items: Array<ItemButton> = [], microphoneHandler: MicrophoneHandler) {
        self.vm = vm
        _microphoneHandler = ObservedObject(wrappedValue: microphoneHandler)
    }
    
    
    
    var body: some View {
        Grid {
            GridRow {
                SystemItemButton(icon:"clipboard",onTap: {
                    vm?.openClipboard()
                }, label: "✨ Clipboard History")
                SystemItemButton(icon: "keyboard", onTap: {
                    vm?.close()
                    vm?.toggleSneakPeak(status: true, type: .backlight, value: 1)
                }, label: "💡 Keyboard Backlight")
            }
            GridRow {
                SystemItemButton(icon:"mic", onTap: {
                    microphoneHandler.toggleMicrophone()
                    vm?.close()
                }, label: (microphoneHandler.currentMicStatus ? "😀" : "🤫") + " Toggle Microphone")
                SystemItemButton(icon: "lock", onTap: {
                    logout()
                }, label: "🔒 Lock My Device")
            }
        }
    }
    
}

#Preview {
    BoringSystemTiles(vm:BoringViewModel(), microphoneHandler: MicrophoneHandler(vm:.init())).padding()
}

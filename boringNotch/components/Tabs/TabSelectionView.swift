//
//  TabSelectionView.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-25.
//

import SwiftUI

struct TabSelectionView: View {
    @EnvironmentObject var vm: BoringViewModel
    var body: some View {
        HStack {
            TabButton(label: "Home", icon: "house.fill", selected: vm.currentView == .home) {
                vm.currentView = .home
            }
            TabButton(label: "Shelf", icon: "tray.fill", selected: vm.currentView == .shelf) {
                vm.currentView = .shelf
            }
        }
    }
}

#Preview {
    BoringNotch(vm: BoringViewModel(), batteryModel: BatteryStatusViewModel(vm: .init()), onHover: onHover, clipboardManager: ClipboardManager(vm:.init()), microphoneHandler: MicrophoneHandler(vm:.init()))
        .frame(width: 600, height: 500)
}

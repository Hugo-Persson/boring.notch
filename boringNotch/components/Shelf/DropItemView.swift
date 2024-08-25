//
//  TrayDrop+DropItemView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Foundation
import Pow
import SwiftUI
import UniformTypeIdentifiers

struct DropItemView: View {
    let item: TrayDrop.DropItem
    @EnvironmentObject var vm: BoringViewModel
    @StateObject var tvm = TrayDrop.shared

    @State var hover = false

    var body: some View {
        VStack {
            Image(nsImage: item.workspacePreviewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 64)
            Text(item.fileName)
                .multilineTextAlignment(.center)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: 64)
        }
        .contentShape(Rectangle())
        .onHover { hover = $0 }
        .scaleEffect(hover ? 1.05 : 1.0)
        .animation(vm.animation, value: hover)
        .onDrag { NSItemProvider(contentsOf: item.storageURL) ?? .init() }
        .overlay {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.red)
                .background(Color.white.clipShape(Circle()).padding(1))
                .frame(width: vm.spacing, height: vm.spacing)
                .opacity(vm.optionKeyPressed ? 1 : 0) // TODO: Use option key pressed to show delete
                .scaleEffect(vm.optionKeyPressed ? 1 : 0.5)
                .animation(vm.animation, value: vm.optionKeyPressed)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: vm.spacing / 2, y: -vm.spacing / 2)
                .onTapGesture { tvm.delete(item.id) }
        }
    }
}

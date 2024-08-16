import SwiftUI
import AVFoundation
import Combine
import KeyboardShortcuts

struct ContentView: View {
    let onHover: () -> Void
    @EnvironmentObject var vm: BoringViewModel
    @StateObject var batteryModel: BatteryStatusViewModel
    var clipboardManager: ClipboardManager?
    @StateObject var microphoneHandler: MicrophoneHandler
    
    var body: some View {
        BoringNotch(vm: vm, batteryModel: batteryModel, onHover: onHover, clipboardManager: clipboardManager!, microphoneHandler: microphoneHandler)
            .frame(maxWidth: .infinity, maxHeight: Sizes().size.opened.height! + 20, alignment: .top)
            .edgesIgnoringSafeArea(.top)
            .transition(.slide.animation(vm.animation))
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    withAnimation(vm.animation){
                        if vm.firstLaunch {
                            vm.open()
                        }
                    }
                })
            })
            .animation(.smooth().delay(0.3), value: vm.firstLaunch)
            .contextMenu {
                SettingsLink(label: {
                    Text("Settings")
                })
                .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
                Button("Edit") {
                    let dn = DynamicNotch(content: EditPanelView())
                    dn.toggle()
                }
#if DEBUG
                .disabled(false)
#else
                .disabled(true)
#endif
                .keyboardShortcut("E", modifiers: .command)
            }.onHover(perform: { hovering in
                clipboardManager?.captureClipboardText()
            })
            .floatingPanel(isPresented: $vm.showCHPanel) {
                ClipboardView(clipboardManager: clipboardManager!)
                    .environmentObject(vm)
            }
    }
}

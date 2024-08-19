//
    //  BoringNotch.swift
    //  boringNotch
    //
    //  Created by Harsh Vardhan  Goswami  on 04/08/24.
    //

import SwiftUI

var notchAnimation = Animation.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8)

struct BoringNotch: View {
    @StateObject var vm: BoringViewModel
    let onHover: () -> Void
    @State private var isExpanded = false
    @State var showEmptyState = false
    @StateObject private var musicManager: MusicManager
    @StateObject private var volumeChangeListener: VolumeChangeListener
    @StateObject var batteryModel: BatteryStatusViewModel
    private var clipboardManager: ClipboardManager?
    @StateObject var microphoneHandler: MicrophoneHandler
    @State private var haptics: Bool = false
    @State var dropTargeting: Bool = false
    
    @State private var hoverStartTime: Date?
    @State private var hoverTimer: Timer?
    @State private var hoverAnimation: Bool = false
    
    init(vm: BoringViewModel, batteryModel: BatteryStatusViewModel, onHover: @escaping () -> Void, clipboardManager: ClipboardManager, microphoneHandler: MicrophoneHandler) {
        _vm = StateObject(wrappedValue: vm)
        _musicManager = StateObject(wrappedValue: MusicManager(vm: vm)!)
        _volumeChangeListener = StateObject(wrappedValue: VolumeChangeListener(vm: vm))
        _batteryModel = StateObject(wrappedValue: batteryModel)
        self.clipboardManager = clipboardManager
        _microphoneHandler =  StateObject(wrappedValue: microphoneHandler)
        self.onHover = onHover
    }
    
    func calculateNotchWidth() -> CGFloat {
        let isFaceVisible = (musicManager.isPlayerIdle ? vm.nothumanface: true) || musicManager.isPlaying
        let baseWidth = vm.sizes.size.closed.width ?? 0
        
        let notchWidth: CGFloat = vm.notchState == .open
        ? vm.sizes.size.opened.width!
        : vm.expandingView.show
        ? baseWidth + 160
        : CGFloat(vm.firstLaunch ? 50 : 0) + baseWidth + (isFaceVisible ? 65 : 0)
        
        return notchWidth + (hoverAnimation ? 16 : 0)
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(.black)
            .mask(NotchShape(cornerRadius: vm.notchState == .open ? vm.sizes.cornerRadius.opened.inset : (vm.sneakPeak.show ? 4 : 0) + vm.sizes.cornerRadius.closed.inset!))
            .frame(width: calculateNotchWidth(), height: vm.notchState == .open ? (vm.sizes.size.opened.height!) : vm.sizes.size.closed.height! + (hoverAnimation ? 8 : !vm.expandingView.show && vm.sneakPeak.show ? 35 : 0))
            .animation(notchAnimation, value: vm.expandingView.show)
            .animation(notchAnimation, value: musicManager.isPlaying)
            .animation(notchAnimation, value: musicManager.lastUpdated)
            .animation(notchAnimation, value: musicManager.isPlayerIdle)
            .animation(.smooth, value: vm.firstLaunch)
            .animation(notchAnimation, value: vm.sneakPeak.show)
            .background(dragDetector)
            .overlay {
                NotchContentView(clipboardManager: clipboardManager, microphoneHandler: microphoneHandler)
                    //.environmentObject(DownloadWatcher(folderPath: nil, vm: vm))
                    .environmentObject(vm)
                    .environmentObject(musicManager)
                    .environmentObject(batteryModel)
                    .environmentObject(volumeChangeListener)
            }
            .clipped()
            .onHover { hovering in
                if hovering {
                    if ((vm.notchState == .closed) && vm.enableHaptics) {
                        haptics.toggle()
                    }
                    
                    if(vm.sneakPeak.show){
                        return;
                    }
                    startHoverTimer()
                } else {
                    vm.notchMetastability = true
                    cancelHoverTimer()
                    if vm.notchState == .open {
                        withAnimation(.smooth) {
                            vm.close()
                            //vm.openMusic()
                        }
                    }
                }
            }
            .shadow(color: vm.notchState == .open ? .black : hoverAnimation ? .black.opacity(0.5) : .clear, radius: 10)
            .sensoryFeedback(.levelChange, trigger: haptics)
            .environmentObject(vm)
    }
    
    
    private func startHoverTimer() {
        hoverStartTime = Date()
        hoverTimer?.invalidate()
        withAnimation(vm.animation) {
            hoverAnimation = true
        }
        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkHoverDuration()
        }
    }
    
    func doOpen(){
        
        withAnimation() {
            vm.open()
            vm.notchMetastability = false
        }
        cancelHoverTimer()
    }
    
    private func checkHoverDuration() {
        guard let startTime = hoverStartTime else { return }
        let hoverDuration = Date().timeIntervalSince(startTime)
        if hoverDuration >= vm.minimumHoverDuration {
            doOpen()
        }
    }
    
    private func cancelHoverTimer() {
        hoverTimer?.invalidate()
        hoverTimer = nil
        hoverStartTime = nil
        withAnimation(vm.animation) {
            hoverAnimation = false
        }
    }
    
    @ViewBuilder
    var dragDetector: some View {
        Rectangle()
            .foregroundStyle(Color.black.opacity(0.001)) // fuck you apple and 0.001 is the smallest we can have
            .contentShape(Rectangle())
            .frame(width: calculateNotchWidth())
            .onDrop(of: [.data], isTargeted: $dropTargeting) { _ in true }
            .onChange(of: dropTargeting) { _, isTargeted in
                if isTargeted, vm.notchState == .closed {
                    // Open the notch when a file is dragged over it
                    vm.currentView = .shelf
                    doOpen()
                } else if !isTargeted {
                    // Close the notch when the dragged item leaves the area
                    let mouseLocation: NSPoint = NSEvent.mouseLocation
                    let openedHeight = vm.sizes.size.opened.height!
                    let openedWidth = calculateNotchWidth()
                    guard let screen = NSScreen.main else { return }
                    let screenRect = screen.visibleFrame
                    let rect = CGRect(
                        x: screenRect.origin.x + (screenRect.width - openedWidth) / 2,
                        y: screenRect.origin.y + screenRect.height - openedHeight,
                        width: openedWidth,
                        height: openedHeight
                    )
                    if !rect.contains(mouseLocation) {
                        print("Closing notch")
                        withAnimation(.smooth) {
                            vm.close()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

func onHover(){}

#Preview {
    BoringNotch(vm: BoringViewModel(), batteryModel: BatteryStatusViewModel(vm: .init()), onHover: onHover, clipboardManager: ClipboardManager(vm:.init()), microphoneHandler: MicrophoneHandler(vm:.init())).frame(width: 600, height: 500)
}

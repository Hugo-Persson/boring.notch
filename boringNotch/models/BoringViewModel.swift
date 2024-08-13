    //
    //  BoringViewModel.swift
    //  boringNotch
    //
    //  Created by Harsh Vardhan  Goswami  on 04/08/24.
    //

import SwiftUI
import Combine

class BoringViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    
    let animationLibrary: BoringAnimations = BoringAnimations()
    let animation: Animation?
    @Published var contentType: ContentType = .normal
    @Published var notchState: NotchState = .closed
    @Published var currentView: NotchViews = .empty
    @Published var headerTitle: String = "Boring Notch"
    @Published var emptyStateText: String = "Play some jams, ladies, and watch me shine! New features coming soon! 🎶 🚀"
    @Published var sizes : Sizes = Sizes()
    @Published var musicPlayerSizes: MusicPlayerElementSizes = MusicPlayerElementSizes()
    @Published var waitInterval: Double = 3
    @Published var releaseName: String = "Romantic Lady"
    @Published var coloredSpectrogram: Bool = true
    @Published var accentColor: Color = .accentColor
    @Published var selectedDownloadIndicatorStyle: DownloadIndicatorStyle = .progress
    @Published var selectedDownloadIconStyle: DownloadIconStyle = .onlyAppIcon
    @AppStorage("showMenuBarIcon") var showMenuBarIcon: Bool = true
    @Published var enableHaptics: Bool = true
    @Published var nothumanface: Bool = false
    @Published var showBattery: Bool = true
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    @Published var showChargingInfo: Bool = true
    @Published var chargingInfoAllowed: Bool = true
    @AppStorage("showWhatsNew") var showWhatsNew: Bool = true
    @Published var whatsNewOnClose: (() -> Void)?
    @Published var minimumHoverDuration: TimeInterval = 0.3
    
    deinit {
        destroy()
    }
    
    func destroy() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    
    override
    init() {
        self.animation = self.animationLibrary.animation
        super.init()
    }
    
    func open(){
        self.notchState = .open
    }
    
    func close(){
        self.notchState = .closed
    }
    
    func openMenu(){
        self.currentView = .menu
    }
    
    func openMusic(){
        self.currentView = .music
    }
    
    func showEmpty() {
        self.currentView = .empty
    }
    
    func closeHello() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2){
            self.firstLaunch = false;
            withAnimation(self.animationLibrary.animation){
                self.close()
            }
        }
    }
}


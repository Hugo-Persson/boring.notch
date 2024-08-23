    //
    //  NotchContentView.swift
    //  boringNotch
    //
    //  Created by Richard Kunkli on 13/08/2024.
    //

import SwiftUI

private var appIcons: AppIcons = AppIcons()

struct NotchContentView: View {
    @EnvironmentObject var vm: BoringViewModel
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var batteryModel: BatteryStatusViewModel
    @EnvironmentObject var volumeChangeListener: VolumeChangeListener
    var clipboardManager: ClipboardManager?
    @StateObject var microphoneHandler: MicrophoneHandler
        //    @EnvironmentObject var downloadWatcher: DownloadWatcher
    @ObservedObject var webcamManager: WebcamManager
    
    var body: some View {
        VStack(alignment: vm.firstLaunch ? .center : .leading, spacing: 0) {
            if vm.notchState == .open {
                BoringHeader(vm: vm, percentage: batteryModel.batteryPercentage, isCharging: batteryModel.isPluggedIn).animation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8), value: vm.notchState).padding(.top, 10)
            if vm.firstLaunch {
                    Spacer()
                    HelloAnimation().frame(width: 180, height: 60).onAppear(perform: {
                        vm.closeHello()
                    })
                    Spacer()
                }
            }
            
            if !vm.firstLaunch {
                HStack(spacing: 14) {
                    if vm.notchState == .closed && vm.expandingView.show {
                        if(vm.expandingView.type == .battery){
                            Text("Charging").foregroundStyle(.white).padding(.leading, 4)
                        }
                        else {
                            if vm.expandingView.browser == .safari {
                                Image(nsImage: appIcons.getIcon(bundleID: "com.apple.safari")!)
                            } else {
                                Image(.chrome).resizable().scaledToFit().frame(width: 30, height: 30)
                            }
                            
                        }
                    }
                    if !vm.expandingView.show && vm.currentView != .menu  {
                        HStack (spacing: 6){
                            ZStack {
                                Image(nsImage: musicManager.albumArt)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: vm.notchState == .open ? vm.musicPlayerSizes.image.size.opened.width : vm.musicPlayerSizes.image.size.closed.width,
                                        height: vm.notchState == .open ? vm.musicPlayerSizes.image.size.opened.height : vm.musicPlayerSizes.image.size.closed.height
                                    )
                                    .cornerRadius(vm.notchState == .open ? vm.musicPlayerSizes.image.cornerRadius.opened.inset! : vm.musicPlayerSizes.image.cornerRadius.closed.inset!)
                                    .scaledToFit()
                                    .padding(.leading, vm.notchState == .open ? -10 : 6)
                                
                                if vm.notchState == .open {
                                    Image(nsImage: appIcons.getIcon(bundleID: musicManager.bundleIdentifier)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: vm.notchState == .open ? 30 : 10, height: vm.notchState == .open ? 30 : 10)
                                        .padding(.leading, vm.notchState == .open ? 70 : 20)
                                        .padding(.top, vm.notchState == .open ? 75 : 15)
                                        .transition(.scale.combined(with: .opacity).animation(.bouncy.delay(0.3)))
                                }
                            }
                            if vm.notchState == .open {
                                VStack(alignment: .leading, spacing: 0) {
                                    GeometryReader { geo in
                                        VStack(alignment: .leading, spacing: 3){
                                            MarqueeText(musicManager.songTitle, font: .headline, nsFont: .headline, textColor: .white, frameWidth: geo.size.width)
                                            MarqueeText(musicManager.artistName, font: .subheadline, nsFont: .subheadline, textColor: .gray, frameWidth: geo.size.width)
                                        }
                                    }.padding(.top)
                                    HStack(spacing: 0) {
                                        Button {
                                            musicManager.previousTrack()
                                        } label: {
                                            Rectangle()
                                                .fill(.clear)
                                                .contentShape(Rectangle())
                                                .frame(width: 30, height: 30)
                                                .overlay {
                                                    Image(systemName: "backward.fill")
                                                        .foregroundColor(.white)
                                                        .imageScale(.medium)
                                                }
                                        }
                                        Button {
                                            print("tapped")
                                            musicManager.togglePlayPause()
                                        } label: {
                                            Rectangle()
                                                .fill(.clear)
                                                .contentShape(Rectangle())
                                                .frame(width: 30, height: 30)
                                                .overlay {
                                                    Image(systemName: musicManager.isPlaying ? "pause.fill" : "play.fill")
                                                        .foregroundColor(.white)
                                                        .contentTransition(.symbolEffect)
                                                        .imageScale(.large)
                                                }
                                        }
                                        Button {
                                            musicManager.nextTrack()
                                        } label: {
                                            Rectangle()
                                                .fill(.clear)
                                                .contentShape(Rectangle())
                                                .frame(width: 30, height: 30)
                                                .overlay {
                                                    Capsule()
                                                        .fill(.black)
                                                        .frame(width: 30, height: 30)
                                                        .overlay {
                                                            Image(systemName: "forward.fill")
                                                                .foregroundColor(.white)
                                                                .imageScale(.medium)
                                                            
                                                        }
                                                }
                                        }
                                    }
                                }
                                .allowsHitTesting(!vm.notchMetastability)
                                .transition(.blurReplace.animation(.spring(.bouncy(duration: 0.3)).delay(vm.notchState == .closed ? 0 : 0.1)))
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    
                    if (vm.currentView != .menu) && vm.notchState != .open {
                        Spacer()
                    }
                    
                    if musicManager.isPlayerIdle == true && vm.notchState == .closed && !vm.expandingView.show && vm.nothumanface {
                        MinimalFaceFeatures().transition(.blurReplace.animation(.spring(.bouncy(duration: 0.3))))
                    }
                    
                    
                    if vm.currentView != .menu && vm.notchState == .closed && vm.expandingView.show  {
                        if vm.expandingView.type == .battery {
                            BoringBatteryView(batteryPercentage: batteryModel.batteryPercentage, isPluggedIn: batteryModel.isPluggedIn, batteryWidth: 30)
                        } else {
                            ProgressIndicator(type: .text, progress: 0.01, color: vm.accentColor).padding(.trailing, 4)
                        }
                    }
                    
                    if vm.notchState == .closed && !vm.expandingView.show && (musicManager.isPlaying || !musicManager.isPlayerIdle) {
                        MusicVisualizer(avgColor: musicManager.avgColor, isPlaying: musicManager.isPlaying)
                            .frame(width: 30)
                    }
                    
                    
                    if vm.notchState == .open {
                        BoringSystemTiles(vm: vm, microphoneHandler: microphoneHandler)
                            .transition(.blurReplace.animation(.spring(.bouncy(duration: 0.3)).delay(0.1)))
                            .allowsHitTesting(!vm.notchMetastability)
                        if vm.showMirror {
                            CircularPreviewView(webcamManager: webcamManager)
                                .frame(width: 90, height: 90)
                        }
                    }
                }
                .padding(.bottom, vm.expandingView.show ? 0 : vm.notchState == .closed ? 0 : 15)
            }
            
            if ((vm.notchState == .closed && vm.sneakPeak.show ) && (!vm.expandingView.show)) {
                switch vm.sneakPeak.type {
                    case .music:
                        HStack(alignment: .center) {
                            Image(systemName: "music.note")
                                .padding(.leading, 4)
                            GeometryReader { geo in
                                MarqueeText(musicManager.songTitle, font: .headline, nsFont: .headline, textColor: .gray, frameWidth: geo.size.width).padding(.top, -3)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundStyle(.gray, .gray).transition(.blurReplace.animation(.spring(.bouncy(duration: 0.3)).delay(0.1))).padding(2)
                    case .volume:
                        SystemEventIndicatorModifier(eventType: .volume, value: $vm.sneakPeak.value, sendEventBack: { newVolume in
                            volumeChangeListener.setVolume(Float(newVolume))
                        })
                        .transition(.opacity.combined(with: .blurReplace))
                        .padding([.leading, .top], musicManager.isPlaying ? 4 : 0)
                        .padding(.trailing, musicManager.isPlaying ? 8 : 4)
                    case .brightness:
                        SystemEventIndicatorModifier(eventType: .brightness, value: $vm.sneakPeak.value, sendEventBack: {
                            newBrigthness in try? DisplayManager.setDisplayBrightness(Float(newBrigthness))
                        })
                        .transition(.opacity.combined(with: .blurReplace))
                        .padding([.leading, .top], musicManager.isPlaying ? 4 : 0)
                        .padding(.trailing, musicManager.isPlaying ? 8 : 4)
                    case .backlight:
                        SystemEventIndicatorModifier(eventType: .backlight, value: $vm.sneakPeak.value, sendEventBack: {
                            newBacklight in KeyLightManager(vm: vm).setKeyboardBacklight(brightness: Float(newBacklight))
                        })
                        .transition(.opacity.combined(with: .blurReplace))
                        .padding([.leading, .top], musicManager.isPlaying ? 4 : 0)
                        .padding(.trailing, musicManager.isPlaying ? 8 : 4)
                    case .mic:
                        SystemEventIndicatorModifier(eventType: .mic, value: $vm.sneakPeak.value, sendEventBack: {
                            newMicValue in print("newMicValue")
                        }).transition(.opacity.combined(with: .blurReplace))
                            .padding([.leading, .top], musicManager.isPlaying ? 4 : 0)
                            .padding(.trailing, musicManager.isPlaying ? 8 : 4)
                    default:
                        EmptyView()
                }
            }
            
                //            if vm.notchState == .open && !downloadWatcher.downloadFiles.isEmpty {
                //                DownloadArea().padding(.bottom, 15).transition(.blurReplace.animation(.spring(.bouncy(duration: 0.5)))).environmentObject(downloadWatcher)
                //            }
        }
        .frame(width: calculateFrameWidthforNotchContent())
        .transition(.blurReplace.animation(.spring(.bouncy(duration: 0.5))))
    }
    
    func calculateFrameWidthforNotchContent() -> CGFloat? {
            // Calculate intermediate values
        let chargingInfoWidth: CGFloat = vm.expandingView.show ? ((vm.expandingView.type == .download ? downloadSneakSize.width : batterySenakSize.width) + 10) : 0
        let musicPlayingWidth: CGFloat = (!vm.firstLaunch && !vm.expandingView.show && (musicManager.isPlaying || (musicManager.isPlayerIdle ? vm.nothumanface : true))) ? 60 : -15
        
        let closedWidth: CGFloat = vm.sizes.size.closed.width! - 5
        
        let dynamicWidth: CGFloat = chargingInfoWidth + musicPlayingWidth + closedWidth
            // Return the appropriate width based on the notch state
        return vm.notchState == .open ? vm.musicPlayerSizes.player.size.opened.width! + 30 : dynamicWidth + (vm.sneakPeak.show ? -12 : 0)
    }
}

#Preview {
    BoringNotch(vm: BoringViewModel(), batteryModel: BatteryStatusViewModel(vm: .init()), onHover: onHover, clipboardManager: ClipboardManager(vm: .init()), microphoneHandler: MicrophoneHandler(vm:.init())).frame(width: 800, height: 600)
}

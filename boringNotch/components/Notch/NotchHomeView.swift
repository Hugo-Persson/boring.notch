//
//  NotchHomeView.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-18.
//

import SwiftUI

struct NotchHomeView: View {
    @EnvironmentObject var vm: BoringViewModel
    @EnvironmentObject var microphoneHandler: MicrophoneHandler
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var batteryModel: BatteryStatusViewModel
    @EnvironmentObject var volumeChangeListener: VolumeChangeListener
    @EnvironmentObject var webcamManager: WebcamManager
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 3) {
                    MarqueeText(musicManager.songTitle, font: .headline, nsFont: .headline, textColor: .white, frameWidth: geo.size.width)
                    MarqueeText(musicManager.artistName, font: .subheadline, nsFont: .subheadline, textColor: .gray, frameWidth: geo.size.width)
                }
            }
            .padding(.top)
            HStack(spacing: 5) {
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
        
        BoringSystemTiles(vm: vm, microphoneHandler: microphoneHandler)
                                    .transition(.blurReplace.animation(.spring(.bouncy(duration: 0.3)).delay(0.1)))
                                if vm.showMirror {
                                    CircularPreviewView(webcamManager: webcamManager)
                                        .frame(width: 90, height: 90)
                                }
    }
}


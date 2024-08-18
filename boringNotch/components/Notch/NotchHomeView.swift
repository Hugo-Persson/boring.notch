//
//  NotchHomeView.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-18.
//

import SwiftUI

struct NotchHomeView: View {
    @EnvironmentObject var vm: BoringViewModel
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var batteryModel: BatteryStatusViewModel
    @EnvironmentObject var volumeChangeListener: VolumeChangeListener
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 3) {
                Text(musicManager.songTitle)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(musicManager.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
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
    }
}

#Preview {
    NotchHomeView()
}

    //
    //  SettingsView.swift
    //  boringNotch
    //
    //  Created by Richard Kunkli on 07/08/2024.
    //

import SwiftUI
import LaunchAtLogin
import Sparkle
import KeyboardShortcuts

struct SettingsView: View {
    @EnvironmentObject var vm: BoringViewModel
    let updaterController: SPUStandardUpdaterController
    
    @State private var selectedTab: SettingsEnum = .general
    @State private var showBuildNumber: Bool = false
    let accentColors: [Color] = [.blue, .purple, .pink, .red, .orange, .yellow, .green, .gray]
    
    var body: some View {
        TabView(selection: $selectedTab,
                content:  {
            GeneralSettings()
                .tabItem { Label("General", systemImage: "gear") }
                .tag(SettingsEnum.general)
            Media()
                .tabItem { Label("Media", systemImage: "play.laptopcomputer") }
                .tag(SettingsEnum.mediaPlayback)
            HUD()
                .tabItem { Label("HUDs", systemImage: "dial.medium.fill") }
                .tag(SettingsEnum.hud)
            Charge()
                .tabItem { Label("Battery", systemImage: "battery.100.bolt") }
                .tag(SettingsEnum.charge)
            Downloads()
                .tabItem { Label("Downloads", systemImage: "square.and.arrow.down") }
                .tag(SettingsEnum.download)
            Shelf()
                .tabItem { Label("Shelf", systemImage: "books.vertical") }
                .tag(SettingsEnum.shelf)
            Clip()
                .tabItem { Label("Clipboard", systemImage: "clipboard") }
                .tag(SettingsEnum.clip)
            About()
                .tabItem { Label("About", systemImage: "info.circle") }
                .tag(SettingsEnum.about)
        })
        .formStyle(.grouped)
        .frame(width: 600, height: 500)
        .tint(vm.accentColor)
    }
    
    @ViewBuilder
    func GeneralSettings() -> some View {
        Form {
            warningBadge("Your Settings will not be restored on restart", "By doing this, we can quickly address global bugs. It will be enabled later on.")
            
            Section {
                HStack() {
                    ForEach(accentColors, id: \.self) { color in
                        Button(action: {
                            withAnimation {
                                vm.accentColor = color
                            }
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: vm.accentColor == color ? 2 : 0)
                                        .overlay {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 7, height: 7)
                                                .opacity(vm.accentColor == color ? 1 : 0)
                                        }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                    ColorPicker("Custom color", selection: $vm.accentColor)
                        .labelsHidden()
                }
            } header: {
                Text("Accent color")
            }
            
            boringControls()
            
            NotchBehaviour()
        }
    }
    
    @ViewBuilder
    func Charge() -> some View {
        Form {
            Toggle("Show charging indicator", isOn: $vm.chargingInfoAllowed)
            Toggle("Show battery indicator", isOn: $vm.showBattery.animation())
        }
    }
    
    @ViewBuilder
    func Downloads() -> some View {
        Form {
            warningBadge("We don't support safari downloads yet", "It will be supported later on.")
            Section {
                Toggle("Show download progress", isOn: $vm.enableDownloadListener)
                Toggle("Enable Safari Downloads", isOn: $vm.enableSafariDownloads).disabled(!vm.enableDownloadListener)
                Picker("Download indicator style", selection: $vm.selectedDownloadIndicatorStyle) {
                    Text("Progress bar")
                        .tag(DownloadIndicatorStyle.progress)
                    Text("Percentage")
                        .tag(DownloadIndicatorStyle.percentage)
                }
                Picker("Download icon style", selection: $vm.selectedDownloadIconStyle) {
                    Text("Only app icon")
                        .tag(DownloadIconStyle.onlyAppIcon)
                    Text("Only download icon")
                        .tag(DownloadIconStyle.onlyIcon)
                    Text("Both")
                        .tag(DownloadIconStyle.iconAndAppIcon)
                }
                
            } header: {
                HStack {
                    Text("Download indicators")
                    comingSoonTag()
                }
            }
            Section {
                List {
                    ForEach(0..<1) { _ in
                        Text("No excludes")
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 0) {
                        Button {} label: {
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "plus").imageScale(.small)
                                }
                        }
                        Divider()
                        Button {} label: {
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "minus").imageScale(.small)
                                }
                        }
                    }
                    .disabled(true)
                    .buttonStyle(PlainButtonStyle())
                }
            } header: {
                HStack (spacing: 4){
                    Text("Exclude apps")
                    comingSoonTag()
                }
                
            }
        }
    }
    
    @ViewBuilder
    func HUD() -> some View {
        Form {
            Section {
                Toggle("Enable HUD replacement", isOn: .constant(false))
                Toggle("Enable glowing effect", isOn: $vm.systemEventIndicatorShadow.animation())
                Toggle("Use accent color", isOn: $vm.systemEventIndicatorUseAccent.animation())
            } header: {
                HStack {
                    Text("Customization")
                    comingSoonTag()
                }
            }
            
            Section {
                KeyboardShortcuts.Recorder("Microphone toggle shortcut", name: .toggleMicrophone)
                VStack {
                    KeyboardShortcuts.Recorder("Keyboard backlight up", name: .decreaseBacklight)
                    KeyboardShortcuts.Recorder("Keyboard backlight down", name: .increaseBacklight)}
            } header :{
                Text("Keyboard shortcuts")
            }
        }
    }
    
    @ViewBuilder
    func Media() -> some View {
        Form {
            Section {
                Toggle("Enable colored spectrograms", isOn: $vm.coloredSpectrogram.animation())
                Toggle("Enable sneak peek", isOn: $vm.enableSneakPeek)
                HStack {
                    Stepper(value: $vm.waitInterval, in: 0...10, step: 1) {
                        HStack {
                            Text("Media inactivity timeout")
                            Spacer()
                            Text("\(vm.waitInterval, specifier: "%.0f") seconds")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Media playback live activity")
            }
        }
        .formStyle(.grouped)}
    
    @ViewBuilder
    func boringControls() -> some View {
        Section {
            
            Toggle("Show cool face animation while inactivity", isOn: $vm.nothumanface.animation())
            LaunchAtLogin.Toggle("Launch at login 🦄")
            Toggle("Enable haptics", isOn: $vm.enableHaptics)
            Toggle("Enable boring mirror", isOn: $vm.showMirror)
            Toggle("Menubar icon", isOn: $vm.showMenuBarIcon)
            Toggle("Settings icon in notch", isOn: $vm.settingsIconInNotch)
        } header: {
            Text("Boring Controls")
        }
    }
    
    @ViewBuilder
    func NotchBehaviour() -> some View {
        Section {
            Slider(value: $vm.minimumHoverDuration, in: 0...1, step: 0.1, minimumValueLabel: Text("0"), maximumValueLabel: Text("1")) {
                HStack {
                    Text("Minimum hover duration")
                    Text("\(vm.minimumHoverDuration, specifier: "%.1f")s")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Notch behavior")
        }
    }
    
    @ViewBuilder
    func About() -> some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Text("Release name")
                        Spacer()
                        Text(vm.releaseName)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        if (showBuildNumber) {
                            Text("(\(Bundle.main.buildVersionNumber ?? ""))")
                                .foregroundStyle(.secondary)
                        }
                        Text(Bundle.main.releaseVersionNumber ?? "unkown")
                            .foregroundStyle(.secondary)
                            .onTapGesture {
                                withAnimation {
                                    showBuildNumber.toggle()
                                }
                            }
                    }
                } header: {
                    Text("Version info")
                }
                
                UpdaterSettingsView(updater: updaterController.updater)
            }
            Button("Quit boring.notch", role: .destructive) {
                exit(0)
            }
            .padding()
            VStack(spacing: 15) {
                HStack(spacing: 30) {
                    Button {
                        NSWorkspace.shared.open(sponsorPage)
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "cup.and.saucer.fill")
                                .imageScale(.large)
                            Text("Support Us")
                                .foregroundStyle(.blue)
                        }
                        .contentShape(Rectangle())
                    }
                    
                    Button {
                        NSWorkspace.shared.open(productPage)
                    } label: {
                        VStack(spacing: 5) {
                            Image("Github")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18)
                            Text("GitHub")
                                .foregroundStyle(.blue)
                        }
                        .contentShape(Rectangle())
                    }
                }
                .buttonStyle(PlainButtonStyle())
                Text("Made with 🫶🏻 by not so boring not.people")
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
        }
    }
    
    @ViewBuilder
    func Shelf() -> some View {
        Form {
            Section {
                Toggle("Enable shelf", isOn: .constant(false))
            } header: {
                comingSoonTag()
            }
            .disabled(true)
        }
    }
    
    @ViewBuilder
    func Clip() -> some View {
        Form {
            Section {
                KeyboardShortcuts.Recorder("Clipboard history panel shortcut", name: .clipboardHistoryPanel)
                
                Toggle("Hide scrollbar", isOn: $vm.clipboardHistoryHideScrollbar)
                
                Toggle("Preserve scroll position", isOn: $vm.clipboardHistoryPreserveScrollPosition)
                
                Picker("Keep history for", selection: .constant(2)) {
                    Text("1 day")
                        .tag(1)
                    Text("1 week")
                        .tag(7)
                    Text("1 month")
                        .tag(30)
                    Text("1 year")
                        .tag(365)
                }
                
                HStack {
                    Text("Clipboard history cache")
                    Spacer()
                    Text("-")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Purge clipboard history")
                    Spacer()
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Delete all")
                            Image(systemName: "trash")
                        }
                        .contentShape(.rect)
                    }
                    .foregroundStyle(.red)
                    .buttonStyle(PlainButtonStyle())
                }
                
            }
#if DEBUG
            .disabled(false)
#else
            .disabled(true)
#endif
        }
    }
    
    func comingSoonTag () -> some View {
        Text("Coming soon")
            .foregroundStyle(.secondary)
            .font(.footnote.bold())
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .background(Color(nsColor: .secondarySystemFill))
            .clipShape(.capsule)
    }
    
    func warningBadge(_ text: String, _ description: String) -> some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading) {
                    Text(text)
                        .font(.headline)
                    Text(description)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}

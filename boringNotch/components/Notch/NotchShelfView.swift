
import SwiftUI

struct NotchShelfView: View {
    @EnvironmentObject var vm: BoringViewModel
    @StateObject var tvm = TrayDrop.shared



    var body: some View {
        panel
            .onDrop(of: [.data], isTargeted: $vm.dropZoneTargeting) { providers in
                vm.dropEvent = true
                DispatchQueue.global().async {
                    tvm.load(providers)
                }
                return true
            }
    }

    var panel: some View {
        Rectangle()
            .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
            .foregroundStyle(.white.opacity(0.1))
            .background(loading)
            .overlay {
                content
                    .padding()
            }
            .animation(vm.animation, value: tvm.items)
            .animation(vm.animation, value: tvm.isLoading)
    }

    var loading: some View {
        Rectangle()
            .foregroundStyle(.white.opacity(0.1))
            .conditionalEffect(
                .repeat(
                    .glow(color: .blue, radius: 50),
                    every: 1.5
                ),
                condition: tvm.isLoading > 0
            )
    }

    var text: String {
        [
            "Drop files here",
            "&",
            NSLocalizedString("Press Option to delete", comment: ""),
        ].joined(separator: " ")
    }

    var content: some View {
        Group{
            if tvm.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray.and.arrow.down.fill").foregroundStyle(.white)
                    Text(text)
                        .multilineTextAlignment(.center)
                        .font(.system(.headline, design: .rounded)).padding(.bottom, 20).foregroundStyle(.white)
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: vm.spacing) {
                        ForEach(tvm.items) { item in
                            DropItemView(item: item)
                        }
                    }
                    .padding(vm.spacing)
                }
                .padding(-vm.spacing)
                .scrollIndicators(.never)
            }
        }
    }
}


import SwiftUI

// MARK: - AquariumManageView
struct AquariumManageView: View {
    @EnvironmentObject var aquarium: AquariumFishList    // shared list
    @Binding var editState: EditState
    @State var isDropdown: Bool = false

    // Local arrays to drive animation and display
    @State private var localSpeed: [Double] = []
    @State private var localScale: [Double] = []
    @State private var rotationAngles: [Double] = []

    var vScale: CGFloat { min(UIScreen.main.bounds.height / 844, 1.2) }

    func speedText(_ value: Double) -> String {
        if value >= 12 { return "fast" }
        if value >= 6 { return "avg" }
        return "slow"
    }

    func scaleText(_ value: Double) -> String {
        if value >= 100 { return "large" }
        if value >= 60 { return "normal" }
        return "small"
    }

    var body: some View {
        ZStack {
            // Background
            Image("fishBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            IconView().padding(.top, 12)

            VStack {
                HStack {
                    Button { editState = .notEditing } label: { Text("< back") }
                    Spacer()
                }
                .padding(.horizontal, 15)
                Spacer()
            }

            // Background layers
            Rectangle()
                .opacity(0.45)
                .colorInvert()
                .cornerRadius(40)
                .frame(
                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                    height: min(UIScreen.main.bounds.width * 0.98, 2000)
                )
                .padding(.bottom, -15)

            Rectangle()
                .opacity(0.25)
                .colorInvert()
                .cornerRadius(50)
                .frame(
                    width: min(UIScreen.main.bounds.width * 0.85, 2000),
                    height: min(UIScreen.main.bounds.width * 1.03, 2000)
                )
                .padding(.bottom, -15)

            VStack(alignment: .leading, spacing: 15) {
                // Header
                HStack {
                    Text("Fish")
                        .animation(.easeInOut(duration: 0.25), value: isDropdown)
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { isDropdown.toggle() }
                    } label: {
                        Image(systemName: isDropdown ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 60)

                ZStack {
                    // Fish list
                    if !isDropdown {
                        VStack(spacing: 8) {
                            ForEach(aquarium.fish.indices, id: \.self) { i in
                                let fish = aquarium.fish[i]

                                ZStack {
                                    Rectangle()
                                        .opacity(0.3)
                                        .colorInvert()
                                        .cornerRadius(5)
                                        .frame(
                                            width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                            height: min(UIScreen.main.bounds.width * 0.25, 2000)
                                        )

                                    HStack {
                                        Spacer().frame(width: 10)

                                        Image(fish.imageName)
                                            .resizable()
                                            .frame(
                                                width: min(UIScreen.main.bounds.width * 0.02, 180),
                                                height: min(UIScreen.main.bounds.width * 0.02, 180)
                                            )
                                            .opacity(0.9)
                                            .background(Circle().colorInvert().opacity(0.5))
                                            // padding increases with local scale
                                            .padding(.horizontal, 15 + (( localScale[safe: i] ?? 50) / 8))
                                            // scale animation based on local slider
                                            .scaleEffect(0.5 + (localScale[safe: i] ?? 5) / 15)
                                            // rotation animation
                                            .rotationEffect(.degrees(rotationAngles[safe: i] ?? 0))
                                            .onAppear {
                                                if localSpeed.isEmpty, !aquarium.fish.isEmpty {
                                                    localSpeed = aquarium.fish.map { 16 - $0.swimDuration }
                                                    localScale = aquarium.fish.map { Double($0.size.width) }
                                                    rotationAngles = Array(repeating: 0, count: aquarium.fish.count)

                                                    for index in aquarium.fish.indices {
                                                        let delay = Double(index) * 0.05
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                                            animateRotation(for: index)
                                                        }
                                                    }
                                                }
                                            }

                                        // Sliders
                                        VStack(alignment: .leading, spacing: 5) {
                                            // Speed slider
                                            HStack(spacing: -2) {
                                                Text(speedText(localSpeed[safe: i] ?? 5))
                                                    .frame(width: 70, alignment: .leading)
                                                Slider(
                                                    value: Binding(
                                                        get: { localSpeed[safe: i] ?? 5 },
                                                        set: { newVal in
                                                            localSpeed[safe: i] = newVal
                                                            aquarium.updateSpeed(for: fish, to: 16 - newVal)
                                                            animateRotation(for: i)
                                                        }
                                                    ),
                                                    in: 1...15
                                                )
                                            }

                                            // Scale slider
                                            HStack(spacing: -2) {
                                                Text(scaleText(localScale[safe: i] ?? 50))
                                                    .frame(width: 70, alignment: .leading)
                                                Slider(
                                                    value: Binding(
                                                        get: { localScale[safe: i] ?? 50 },
                                                        set: { newVal in
                                                            localScale[safe: i] = newVal
                                                            let newHeight = fish.size.height * newVal / fish.size.width
                                                            aquarium.updateSize(for: fish, to: CGSize(width: newVal, height: newHeight))
                                                        }
                                                    ),
                                                    in: 20...150
                                                )
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        Spacer().frame(width: 10)
                                    }
                                    .padding(.horizontal, 60)
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                        .transition(.opacity)
                        .padding(.bottom, 20)
                    }

                    // Dropdown content
                    if isDropdown {
                        VStack(alignment: .leading, spacing: 40) {
                            HStack {
                                Text("Filter status")
                                Button {} label: {
                                    Image("med").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                    )
                                }.padding(.horizontal, 20)
                                Text("94%")
                                    .padding(.horizontal, -25)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.035))
                            }.padding(.top, 25)

                            HStack {
                                Text("Customize")
                                Button {} label: {
                                    Image("colorWheel").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.09, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.09, 2000)
                                    )
                                }.padding(.horizontal, 20)
                            }

                            HStack {
                                Text("Clear")
                                Button {} label: {
                                    Image("clear").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.09, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.09, 2000)
                                    )
                                }.padding(.horizontal, 20)
                            }

                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 20 * vScale)
                        }
                        .padding(.horizontal, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }

            // Bottom overlay
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Helper
    func animateRotation(for index: Int) {
        guard index < rotationAngles.count else { return }
        let direction = Bool.random() ? 1.0 : -1.0
        let duration = max(0.3, 2.0 - ((localSpeed[safe: index] ?? 5) / 5))
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            rotationAngles[safe: index] = 10 * direction
        }
    }
}

// MARK: - Safe Array Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        get { indices.contains(index) ? self[index] : nil }
        set { if indices.contains(index), let value = newValue { self[index] = value } }
    }
}

// MARK: - Preview
#Preview {
    AquariumManageView(editState: Binding.constant(.editing))
        .environmentObject(AquariumFishList())
}


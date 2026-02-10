import SwiftUI


struct AquariumManageView: View {
    @Binding var editState: EditState
    @State var isDropdown: Bool = true

    @State private var speedValues: [Double] = [5, 5, 5] // 1..10
    @State private var scaleValues: [Double] = [5, 5, 5] // 1..10
    @State private var rotationAngles: [Double] = [0, 0, 0]

    func speedText(_ value: Double) -> String {
        if value >= 7 { return "fast" }
        if value >= 4 { return "avg" }
        return "slow"
    }

    func scaleText(_ value: Double) -> String {
        if value >= 7 { return "large" }
        if value >= 4 { return "normal" }
        return "small"
    }

    var vScale: CGFloat { min(UIScreen.main.bounds.height / 844, 1.2) }

    var body: some View {
        ZStack {

            Image("fishBackground")
                .resizable().scaledToFill()
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

                HStack {
                    Text("Fish")
                        .animation(.easeInOut(duration: 0.25), value: isDropdown)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isDropdown.toggle()
                        }
                    } label: {
                        Image(systemName: isDropdown ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.black)
                    }

                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 60)

                ZStack {

                    if !isDropdown {
                        VStack(spacing: 8) {

                            ForEach(0..<3, id: \.self) { i in

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

                                        Image(["puffer", "clownfishIcon", "grouper"][i])
                                            .resizable()
                                            .frame(
                                                width: min(UIScreen.main.bounds.width * 0.13, 180),
                                                height: min(UIScreen.main.bounds.width * 0.13, 180)
                                            )
                                            .opacity(0.9)
                                            .background(
                                                Circle().colorInvert().opacity(0.5)
                                            )
                                            // ✅ scale based on slider
                                            .scaleEffect(0.5 + (scaleValues[i] / 10))
                                            // ✅ rotation animation
                                            .rotationEffect(.degrees(rotationAngles[i]))
                                            .onAppear {
                                                let minAngle = 5.0
                                                let maxAngle = 10.0
                                                let direction = Bool.random() ? 1.0 : -1.0

                                                // use speedValues[i] to control duration: faster = shorter duration
                                                let duration = max(0.3, 2.0 - (speedValues[i] / 5))

                                                withAnimation(
                                                    Animation.easeInOut(duration: duration)
                                                        .repeatForever(autoreverses: true)
                                                ) {
                                                    rotationAngles[i] = maxAngle * direction
                                                }
                                            }

                                        VStack(alignment: .leading, spacing: 5) {

                                            HStack(spacing: 1.5 * scaleValues[i] - 8) {
                                                Text(speedText(speedValues[i])).padding(.horizontal,  1.5 * scaleValues[i] - 6)
                                                    .frame(width: 70, alignment: .leading)
                                                Slider(value: $speedValues[i], in: 1...10)
                                                    .onChange(of: speedValues[i]) { _ in
                                                        // force reapply animation when speed changes
                                                        let minAngle = 5.0
                                                        let maxAngle = 10.0
                                                        let direction = Bool.random() ? 1.0 : -1.0
                                                        let duration = max(0.3, 2.0 - (speedValues[i] / 5))
                                                        withAnimation(
                                                            Animation.easeInOut(duration: duration)
                                                                .repeatForever(autoreverses: true)
                                                        ) {
                                                            rotationAngles[i] = maxAngle * direction
                                                        }
                                                    }
                                            }
                                            HStack(spacing: 1.5 * scaleValues[i] - 8) {
                                                Text(scaleText(scaleValues[i])).padding(.horizontal,  1.5 * scaleValues[i] - 6)
                                                    .frame(width: 70, alignment: .leading)
                                                Slider(value: $scaleValues[i], in: 1...10)
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

                    if isDropdown {
                        VStack(alignment: .leading, spacing: 40) {
                            HStack{
                                Text("Filter status")
                                Button {} label: {
                                    Image("med").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                    )
                                }.padding(.horizontal, 20)

                                Text("94%").padding(.horizontal, -25).foregroundStyle(.gray).font(.system(size: UIScreen.main.bounds.width * 0.035))
                            }.padding(.top, 25)

                            HStack{
                                Text("Customize")
                                Button {} label: {
                                    Image("colorWheel").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.09, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.09, 2000)
                                    )
                                }.padding(.horizontal, 20)
                            }

                            HStack{
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
                        .transition(
                            .move(edge: .top).combined(with: .opacity)
                        )
                    }
                }
            }

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    AquariumManageView(editState: Binding.constant(.editing))
}

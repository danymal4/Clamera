//
//  AquariumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

enum EditState {
    case editing, notEditing
}


class AquariumState: ObservableObject {
    @Published var clean: Double = 0.3

    private let maxClean: Double = 0.3
    private let refillDuration: TimeInterval = 60
    private var timer: Timer?

    func cleanNow() {
        // Set clean to 0 immediately
        clean = 0
        
        // Invalidate any previous timer
        timer?.invalidate()
        
        // Start a timer that regenerates smoothly from 0 → maxClean
        let startValue = clean
        let targetValue = maxClean
        let remainingDuration = refillDuration * (targetValue - startValue) / maxClean

        let startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }

            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / remainingDuration, 1.0)
            
            DispatchQueue.main.async {
                self.clean = startValue + (targetValue - startValue) * progress
            }

            if progress >= 1.0 {
                timer.invalidate()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
struct BubbleView: View {
    @EnvironmentObject var aquariumState: AquariumState
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var animationActive = true

    let topY: CGFloat
    let bottomY: CGFloat

    // Persistent random values for each bubble
    @State private var size: CGFloat
    @State private var xPosition: CGFloat
    @State private var duration: Double

    init(topY: CGFloat, bottomY: CGFloat) {
        self.topY = topY
        self.bottomY = bottomY

        // Assign random values once per bubble
        _size = State(initialValue: CGFloat.random(in: 8...20))
        _xPosition = State(initialValue: CGFloat.random(in: 50...(UIScreen.main.bounds.width - 30)))
        _duration = State(initialValue: Double.random(in: 3...7))
    }

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .background(Color.green.opacity(aquariumState.clean * 0.6))
            .frame(width: size, height: size)
            .position(x: xPosition, y: yOffset)
            .opacity(opacity)
            .onAppear {
                animationActive = true
                startAnimation()
            }
            .onDisappear {
                animationActive = false
            }
    }

    func startAnimation() {
        let startYOffset = bottomY + CGFloat.random(in: 0...20)
        yOffset = startYOffset
        opacity = 0

        withAnimation(.easeIn(duration: duration * 0.2)) { opacity = 1 }
        withAnimation(Animation.linear(duration: duration)) { yOffset = topY }
        withAnimation(.easeOut(duration: duration * 0.2).delay(duration * 0.8)) { opacity = 0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if animationActive { startAnimation() }
        }
    }
}

struct AquariumView: View {
    @EnvironmentObject var aquariumState: AquariumState
    @EnvironmentObject var aquarium: AquariumFishList

    @State var editState: EditState = .notEditing
    @State private var bubbleRefreshID = UUID()

    var aquariumTop: CGFloat { UIScreen.main.bounds.height * 0.435 }
    var aquariumBottom: CGFloat { UIScreen.main.bounds.height * 0.58 }

    var body: some View {
        if editState == .notEditing {
            ZStack {

                IconView().padding(.horizontal, 12)

                VStack {
                    Text("Aquarium")
                        .font(.custom(
                            "IslandMoments-Regular",
                            size: UIScreen.main.bounds.width * 0.3
                        ))
                        .opacity(0.9)
                        .foregroundStyle(.blue)

                    ZStack {
                        Image("Aquarium")
                            .resizable()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.7, 2000),
                                height: min(UIScreen.main.bounds.width * 0.8, 700)
                            )
                            .padding(.bottom, 65)
                            .scaleEffect(1.45)

                        Image("floor")
                            .resizable()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.815, 2000),
                                height: min(UIScreen.main.bounds.width * 0.2, 2000)
                            )
                            .padding(.top, 25 + ((UIScreen.main.bounds.width - 402) * 0.3))
                            .padding(.horizontal, 50)
                            .opacity(0.85 - aquariumState.clean)

                        Rectangle()
                            .cornerRadius(5)
                            .foregroundStyle(.green)
                            .opacity(aquariumState.clean)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.84, 2000),
                                height: min(UIScreen.main.bounds.width * 0.46, 2000)
                            )
                            .padding(.bottom, 77)

                        Rectangle()
                            .cornerRadius(5)
                            .foregroundStyle(.blue)
                            .opacity(0.13)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.84, 2000),
                                height: min(UIScreen.main.bounds.width * 0.46, 2000)
                            )
                            .padding(.bottom, 77)

                        HStack {
                            Spacer()

                            Button {
                                // Smooth brush regeneration
                                aquariumState.cleanNow()
                            } label: {
                                Image("brush")
                                    .resizable()
                                    .frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 700)
                                    )
                                    .opacity(aquariumState.clean > 0 ? min(aquariumState.clean * 2.5, 1) : 0)
                                    .animation(.easeInOut(duration: 0.7), value: aquariumState.clean)
                            }
                            .padding(.bottom, 215)
                            .padding(.horizontal, 50)
                            .disabled(aquariumState.clean <= 0)
                        }
                    }
                }

                // Bubbles
                ForEach(0..<8, id: \.self) { _ in
                    BubbleView(
                        
                        topY: aquariumTop,
                        bottomY: aquariumBottom
                    )
                    .id(bubbleRefreshID)
                    .environmentObject(aquariumState)
                }

                FishMoveView(aquarium: aquarium)
                    .opacity(1 - aquariumState.clean)

                VStack {
                    Spacer()

                    ZStack {
                        Button {
                            editState = .editing
                        } label: {
                            Rectangle()
                                .cornerRadius(30)
                                .foregroundStyle(.white)
                                .opacity(0.3)
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    height: min(UIScreen.main.bounds.width * 0.2, 90)
                                )
                        }

                        Text("Manage")
                            .font(.system(size: UIScreen.main.bounds.width * 0.07))
                            .foregroundStyle(.black)
                            .opacity(0.8)
                            .bold()
                    }
                    .padding(.bottom, 40)

                    Rectangle()
                        .colorInvert()
                        .opacity(0.6)
                        .frame(
                            width: min(UIScreen.main.bounds.width * 1, 2000),
                            height: min(UIScreen.main.bounds.width * 0.205, 90)
                        )
                        .padding(.bottom, -330)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                WaterView()
                    .frame(height: UIScreen.main.bounds.height + 400)
                    .offset(y: -130)
                    .allowsHitTesting(false)
            )
            .onAppear {
                bubbleRefreshID = UUID() // Reset bubbles on tab switch
            }
        } else {
            AquariumManageView(editState: $editState)
        }
    }
}


#Preview {
    AquariumView()
        .environmentObject(AquariumFishList())  .environmentObject(AquariumState())
}

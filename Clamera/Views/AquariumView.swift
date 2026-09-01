//
//  AquariumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
import AVFoundation

enum EditState {
    case editing, notEditing
}

struct BubbleView: View {
    @ObservedObject var aquariumState: AquariumState
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9
    @State private var animationActive = true

    let topY: CGFloat
    let bottomY: CGFloat

    @State private var size: CGFloat
    @State private var xPosition: CGFloat
    @State private var duration: Double
    @State private var delayOffset: Double

    init(aquariumState: AquariumState, topY: CGFloat, bottomY: CGFloat) {
        self.aquariumState = aquariumState
        self.topY = topY - 350
        self.bottomY = bottomY + 200

        _size = State(initialValue: CGFloat.random(in: 8...30))
        _xPosition = State(initialValue: CGFloat.random(in: 60...(UIScreen.main.bounds.width - 30)))
        _duration = State(initialValue: Double.random(in: 7...20))
        _delayOffset = State(initialValue: Double.random(in: 0...1))
    }

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.28))
            .overlay(
                Circle()
                    .fill(
                        Color.green.opacity(
                            aquariumState.clean *
                            0.6 *
                            aquariumState.bubbleVisibility *
                            Double.random(in: 0.9...1)
                        )
                    )
            )
            .overlay( // subtle highlight ring
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
            )
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .position(x: xPosition, y: yOffset)
            .opacity(opacity * aquariumState.bubbleVisibility)
            .onAppear {
                animationActive = true
                startAnimation()
            }
            .onDisappear {
                animationActive = false
            }
    }

    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayOffset) {
            guard animationActive else { return }

            let startYOffset = bottomY + CGFloat.random(in: 0...20)

            yOffset = startYOffset
            opacity = 0
            scale = 0.9

            xPosition = CGFloat.random(in: 0...(2 * UIScreen.main.bounds.width))

            withAnimation(.easeIn(duration: duration * 0.2)) {
                opacity = 1
            }

            withAnimation(Animation.linear(duration: duration)) {
                yOffset = topY
            }

            withAnimation(.easeOut(duration: duration)) {
                scale = 1.05
            }

            withAnimation(.easeOut(duration: duration * 0.2).delay(duration * 0.8)) {
                opacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                if animationActive {
                    startAnimation()
                }
            }
        }
    }
}

struct AquariumView: View {
    @EnvironmentObject var user: User
    @Binding var showBottomBar: Bool
    var allowEditing: Bool = true
    @State var editState: EditState = .notEditing
    @State private var bubbleRefreshID = UUID()
    @State private var showAquariumManage = false
    var resetBottomBarTimer: (() -> Void)? = nil

    // Local state variables so friend profile edits happen instantly in real-time without modifying backend user data
    @State private var localBubbleAmount: Double = 1.0
    @State private var bubblePlayer: AVAudioPlayer?

    var aquariumTop: CGFloat { UIScreen.main.bounds.height * 0.435 }
    var aquariumBottom: CGFloat { UIScreen.main.bounds.height * 0.58 }

    var currentBubbleAmount: Double {
        allowEditing ? user.aquariumState.bubbleAmount : localBubbleAmount
    }

    var body: some View {
        ZStack {
            AquariumBackgroundView()
                .environmentObject(user.aquariumState)

            BubbleLayerView(aquariumState: user.aquariumState, bubbleAmount: currentBubbleAmount, topY: aquariumTop, bottomY: aquariumBottom, refreshID: $bubbleRefreshID)
                .offset(y: 645)

            FishMoveView(aquarium: user.aquarium)
                .opacity(1 - user.aquariumState.clean)
                .offset(y: -100)
                .scaleEffect(1.6)

            Rectangle()
                .cornerRadius(5)
                .foregroundStyle(.cyan)
                .opacity(0.14)
                .frame(width: min(UIScreen.main.bounds.width * 2, 2000),
                       height: min(UIScreen.main.bounds.height * 1.2, 2000))
                .padding(.top, -30)
                .edgesIgnoringSafeArea(.bottom)

            // SETTINGS (gear button)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showAquariumManage = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle()) .shadow(color: Color.black.opacity(0.25), radius: 6, x: 2, y: 2)
                    }
                    .padding(.trailing, 400)
                    .padding(.top, 685)
                    .offset(y: showBottomBar ? 0 : 75)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showBottomBar)
                }
            }

            // CHEVRON BUTTON
            VStack {
                Spacer()
                if !showBottomBar {
                    Button {
                        withAnimation(.easeOut(duration: 0.45)) {
                            showBottomBar = true
                        }
                        resetBottomBarTimer?()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray) .shadow(color: Color.black.opacity(0.25), radius: 6, x: 2, y: 2)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .frame(width: 180)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .padding(.bottom, 675)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeOut(duration: 0.4), value: showBottomBar)
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showAquariumManage) {
            if allowEditing {
                AquariumManageView()
                    .environmentObject(user)
            } else {
                NavigationView {
                    Form {
                        Section(header: Text("Friend's Aquarium Settings")) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Bubble Amount: \(String(format: "%.1f", localBubbleAmount))")
                                Stepper("", value: $localBubbleAmount, in: 0.1...3, step: 0.1)
                                    .labelsHidden()
                                    .onChange(of: localBubbleAmount) { _, newValue in
                                        bubbleRefreshID = UUID()
                                        updateBubbleVolume(amount: newValue)
                                    }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .navigationTitle("Bubble Tweak")
                    .navigationBarItems(trailing: Button("Done") {
                        showAquariumManage = false
                    })
                }
            }
        }
        .background(Color.blue.opacity(0.08))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            bubbleRefreshID = UUID()
            if !allowEditing {
                localBubbleAmount = user.aquariumState.bubbleAmount > 0 ? user.aquariumState.bubbleAmount : 1.0
                user.aquariumState.bubbleVisibility = 1.0
            }
            startBubbleSound(amount: currentBubbleAmount)
        }
        .onDisappear {
            stopBubbleSound()
        }
        .onChange(of: user.aquariumState.bubbleAmount) { _, newValue in
            if allowEditing {
                updateBubbleVolume(amount: newValue)
            }
        }
    }

    private func startBubbleSound(amount: Double) {
        guard bubblePlayer == nil else { return }
        guard let url = Bundle.main.url(forResource: "bubble", withExtension: "wav") else { return }
        do {
            bubblePlayer = try AVAudioPlayer(contentsOf: url)
            bubblePlayer?.numberOfLoops = -1
            bubblePlayer?.volume = Float(amount) * 0.5
            bubblePlayer?.play()
        } catch {
            print("Error playing bubble sound: \(error)")
        }
    }

    private func stopBubbleSound() {
        bubblePlayer?.stop()
        bubblePlayer = nil
    }

    private func updateBubbleVolume(amount: Double) {
        bubblePlayer?.volume = Float(amount) * 0.5
    }
}

struct AquariumBackgroundView: View {
    @EnvironmentObject var user: User

    var body: some View {
        ZStack {
            Image("Aquarium")
                .resizable()
                .frame(width: min(UIScreen.main.bounds.width * 2, 2000),
                       height: min(UIScreen.main.bounds.height * 2.5, 2000)).padding(.bottom, 200)

            Image("flatAquarium") .resizable()
                .frame(width: min(UIScreen.main.bounds.width * 1, 2000),
                       height: min(UIScreen.main.bounds.height * 1, 2000)).padding(.bottom, 1300)

            Image("grass2").resizable().frame(width: min(UIScreen.main.bounds.width * 2.9, 2000),
                                              height: min(UIScreen.main.bounds.height * 1.1, 2000))
                .padding(.top, 180 + ((UIScreen.main.bounds.width - 402) * 0.3)).opacity(0.15)

            Image("sandFloor2")
                .resizable()
                .frame(width: min(UIScreen.main.bounds.width * 1.5, 2000),
                       height: min(UIScreen.main.bounds.width * 0.9, 2000))
                .padding(.top, 540 + ((UIScreen.main.bounds.width - 302) * 0.3))
                .padding(.horizontal, 50)
                .opacity(0.95 - (user.aquariumState.clean * 0.25))

            Rectangle()
                .cornerRadius(5)
                .foregroundStyle(.green)
                .opacity(user.aquariumState.clean)
                .frame(width: min(UIScreen.main.bounds.width * 2, 2000),
                       height: min(UIScreen.main.bounds.height * 1.2, 2000))
                .padding(.top, -25).edgesIgnoringSafeArea(.bottom)

            // brush
            HStack {
                Spacer()
                Button {
                    user.aquariumState.cleanNow()
                } label: {
                    Image("brush")
                        .resizable()
                        .frame(width: min(UIScreen.main.bounds.width * 0.22, 2000),
                                height: min(UIScreen.main.bounds.width * 0.22, 700))
                        .opacity(user.aquariumState.clean > 0 ? min(user.aquariumState.clean * 2.5, 1) : 0)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 2, y: 2)
                        .animation(.easeInOut(duration: 0.7), value: user.aquariumState.clean)
                }
                .padding(.top, -400)
                .padding(.horizontal, 395)
                .disabled(user.aquariumState.clean <= 0)
            }
        }
    }
}

struct BubbleLayerView: View {
    @ObservedObject var aquariumState: AquariumState
    let bubbleAmount: Double
    let topY: CGFloat
    let bottomY: CGFloat
    @Binding var refreshID: UUID

    var body: some View {
        ForEach(0..<Int(24 * bubbleAmount), id: \.self) { _ in
            BubbleView(aquariumState: aquariumState, topY: topY, bottomY: bottomY)
                .id(refreshID)
        }
    }
}

#Preview {
    AquariumView(showBottomBar: .constant(true))
        .environmentObject(User())
}

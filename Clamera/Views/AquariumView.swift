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








struct BubbleView: View {
    @EnvironmentObject var user: User
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

    init(topY: CGFloat, bottomY: CGFloat) {
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
                            user.aquariumState.clean *
                            0.6 *
                            user.aquariumState.bubbleVisibility *
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
            .opacity(opacity * user.aquariumState.bubbleVisibility)
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

            // keep your original random spawn
            xPosition = CGFloat.random(in: 0...(2 * UIScreen.main.bounds.width))

            withAnimation(.easeIn(duration: duration * 0.2)) {
                opacity = 1
            }

            // vertical movement (unchanged)
            withAnimation(Animation.linear(duration: duration)) {
                yOffset = topY
            }

            // slight growth while rising (new polish)
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
    @State var editState: EditState = .notEditing
    @State private var bubbleRefreshID = UUID()
    @State private var showAquariumManage = false
    var resetBottomBarTimer: (() -> Void)? = nil

    var aquariumTop: CGFloat { UIScreen.main.bounds.height * 0.435 }
    var aquariumBottom: CGFloat { UIScreen.main.bounds.height * 0.58 }

    var body: some View {
        ZStack {
            AquariumBackgroundView()
                .environmentObject(user.aquariumState)
                // invert

            BubbleLayerView(topY: aquariumTop, bottomY: aquariumBottom, refreshID: $bubbleRefreshID)
                .environmentObject(user)
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

            Rectangle()
                .fill(Color.white)
                .frame(height: 90)
                .cornerRadius(20)
                .shadow(radius: 5)
                .offset(y: showBottomBar ? 0 : 100) // invert
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showBottomBar)
                .padding(.top, 812)

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
                    .padding(.top, 585)
                    .offset(y: showBottomBar ? 0 : 75) // invert
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showBottomBar)
                }
            }

            // CHEVRON BUTTON
            VStack {
                Spacer()
                if !showBottomBar {
                    Button {
                        // Hide the bottom bar manually
                        withAnimation(.easeOut(duration: 0.45)) {
                            showBottomBar = true
                        }
                        // Reset the 5-second timer
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
            AquariumManageView()
        }
        .background(Color.blue.opacity(0.08))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            bubbleRefreshID = UUID()
        }
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
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 2, y: 2) // subtle shadow
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
    @EnvironmentObject var user: User
    let topY: CGFloat
    let bottomY: CGFloat
    @Binding var refreshID: UUID

    var body: some View {
        ForEach(0..<Int(24 * user.aquariumState.bubbleAmount), id: \.self) { _ in
            BubbleView(topY: topY, bottomY: bottomY)
                .id(refreshID)
                .environmentObject(user)
        }
    }
}





#Preview {
    AquariumView(showBottomBar: .constant(true))
        .environmentObject(User())
}

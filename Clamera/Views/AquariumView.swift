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



final class AquariumState: ObservableObject {
    // Current visible clean level in the AquariumView
    @Published var clean: Double = 0.3
    @Published var bubbleVisibility: Double = 1.0
    @Published var bubbleAmount: Double = 1.0
    
    // Maximum clean value
    let maxClean: Double = 0.3
    
    
    // In AquariumState
   

    
    // Tracks the pending clean value accumulated while AquariumView is not visible
    private(set) var pendingClean: Double = 0.3
    
    // Only handle the immediate clean action
    func cleanNow() {
   
            clean = 0
        
        // Update pending value so timer logic elsewhere knows what the target is
        pendingClean = 0
    }
    
    // Call this when AquariumView appears to commit the pending clean value
    func commitPendingClean() {
        // Animate from current clean to pendingClean
        withAnimation(.easeInOut(duration: 0.3)) {
            clean = pendingClean
        }
    }
    
    // External refill logic can update pendingClean at any time
    func updatePendingClean(to value: Double) {
        pendingClean = min(value, maxClean)
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
    @State private var delayOffset: Double // NEW: small random delay

    init(topY: CGFloat, bottomY: CGFloat) {
        self.topY = topY
        self.bottomY = bottomY

        // Assign random values once per bubble
        _size = State(initialValue: CGFloat.random(in: 8...20))
        _xPosition = State(initialValue: CGFloat.random(in: 60...(UIScreen.main.bounds.width - 30)))
        _duration = State(initialValue: Double.random(in: 3...7))
        _delayOffset = State(initialValue: Double.random(in: 0...1)) // 0–1s random delay
    }

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .overlay(
                    Circle()
                        .fill(Color.green.opacity(aquariumState.clean * 0.6 * aquariumState.bubbleVisibility))
                )
            .frame(width: size, height: size)
            .position(x: xPosition, y: yOffset)
            .opacity(opacity * aquariumState.bubbleVisibility)
           
        
        
        
            .onAppear {
                animationActive = true
                startAnimation()  // This actually triggers the bubble movement
            }
            .onDisappear {
                animationActive = false
            }

    }

    func startAnimation() {
        // Add random delay for natural staggering
        DispatchQueue.main.asyncAfter(deadline: .now() + delayOffset) {

            guard animationActive else { return }

            // Randomize vertical start offset
            let startYOffset = bottomY + CGFloat.random(in: 0...20)
            yOffset = startYOffset
            opacity = 0

            // Randomize horizontal position on reset
            xPosition = CGFloat.random(in: 50...(UIScreen.main.bounds.width - 30))

            withAnimation(.easeIn(duration: duration * 0.2)) { opacity = 1 }
            withAnimation(Animation.linear(duration: duration)) { yOffset = topY }
            withAnimation(.easeOut(duration: duration * 0.2).delay(duration * 0.8)) { opacity = 0 }

            // Prepare next animation cycle
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                if animationActive { startAnimation() }
            }
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
                        .font(.custom("IslandMoments-Regular", size: UIScreen.main.bounds.width * 0.3))
                        .opacity(0.9)
                        .foregroundStyle(.blue)
                    
                    ZStack {
                        Image("Aquarium")
                            .resizable()
                            .frame(width: min(UIScreen.main.bounds.width * 0.7, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.8, 700))
                            .padding(.bottom, 65)
                            .scaleEffect(1.45)
                        
                        Image("floor")
                            .resizable()
                            .frame(width: min(UIScreen.main.bounds.width * 0.815, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.2, 2000))
                            .padding(.top, 25 + ((UIScreen.main.bounds.width - 402) * 0.3))
                            .padding(.horizontal, 50)
                            .opacity(0.85 - aquariumState.clean)
                        
                        Rectangle()
                            .cornerRadius(5)
                            .foregroundStyle(.green)
                            .opacity(aquariumState.clean)
                            .frame(width: min(UIScreen.main.bounds.width * 0.84, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.46, 2000))
                            .padding(.bottom, 77)
                        
                        Rectangle()
                            .cornerRadius(5)
                            .foregroundStyle(.blue)
                            .opacity(0.13)
                            .frame(width: min(UIScreen.main.bounds.width * 0.84, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.46, 2000))
                            .padding(.bottom, 77)
                        
                        HStack { Spacer()
                            Button {
                                aquariumState.cleanNow()
                            } label: {
                                Image("brush")
                                    .resizable()
                                    .frame(width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                           height: min(UIScreen.main.bounds.width * 0.12, 700))
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
                ForEach(0..<Int(8 * aquariumState.bubbleAmount), id: \.self) { _ in
                    BubbleView(topY: aquariumTop, bottomY: aquariumBottom)
                        .id(bubbleRefreshID)
                        .environmentObject(aquariumState)
                }
                
                FishMoveView(aquarium: aquarium)
                    .opacity(1 - aquariumState.clean)
                
                VStack {
                    Spacer()
                    ZStack {
                        Button { editState = .editing } label: {
                            Rectangle()
                                .cornerRadius(30)
                                .foregroundStyle(.white)
                                .opacity(0.3)
                                .frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                       height: min(UIScreen.main.bounds.width * 0.2, 90))
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
                        .frame(width: min(UIScreen.main.bounds.width * 1, 2000),
                               height: min(UIScreen.main.bounds.width * 0.205, 90))
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
                bubbleRefreshID = UUID()
                // Commit pendingClean immediately
                aquariumState.commitPendingClean()
                
                // Extra refresh in next run loop to catch small delta
                DispatchQueue.main.async {
                    aquariumState.commitPendingClean()
                }
            }
            .onDisappear {
                // Save clean value when leaving
                aquariumState.updatePendingClean(to: aquariumState.clean)
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

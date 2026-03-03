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
    @Published var clean: Double = 0.3
    @Published var bubbleVisibility: Double = 1.0
    @Published var bubbleAmount: Double = 1.0
    @Published var lastUpdate: Date = Date()
    
    // Track active screens
    @Published var activeScreens: Set<String> = []
    
    let maxClean: Double = 0.3
    private(set) var pendingClean: Double = 0.3
    private var targetClean: Double? = nil
    
    func markActive(_ screen: String) {
        activeScreens.insert(screen)
        commitPendingClean()
    }
    
    func markInactive(_ screen: String) {
        activeScreens.remove(screen)
        pendingClean = clean 
    }
    
    var isActiveScreen: Bool {
        !activeScreens.isEmpty
    }
    
    func updateClean(by increment: Double) {
        if let target = targetClean {
            let delta = (target - clean) * 0.8
            clean += delta
            if abs(clean - target) < 0.01 {
                clean = target
                pendingClean = clean
                targetClean = nil
            }
        } else {
            clean = min(clean + increment, maxClean)
        }
    }
    
    func commitPendingClean() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let target = targetClean, target == 0 {
                // If brush is active, keep the smaller of pendingClean and current clean
                clean = min(pendingClean, clean)
            } else {
                // Otherwise, take the larger to respect increments
                clean = max(pendingClean, clean)
            }
        }
    }
    
    func updatePendingClean(to value: Double) {
        if let target = targetClean {
            let delta = (target - pendingClean) * 0.8
            pendingClean += delta
            if abs(pendingClean - target) < 0.01 {
                pendingClean = target
                targetClean = nil
                clean = pendingClean
            }
        } else {
            pendingClean = min(value, maxClean)
        }
    }
    
    func cleanNow() {
        targetClean = 0
    }
    
    
    
}




struct BubbleView: View {
    @EnvironmentObject var aquariumState: AquariumState
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0
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
      
        DispatchQueue.main.asyncAfter(deadline: .now() + delayOffset) {

            guard animationActive else { return }

            let startYOffset = bottomY + CGFloat.random(in: 0...20)
            yOffset = startYOffset
            opacity = 0

          // random positions
            xPosition = CGFloat.random(in: 0...(2 * UIScreen.main.bounds.width))

            withAnimation(.easeIn(duration: duration * 0.2)) { opacity = 1 }
            withAnimation(Animation.linear(duration: duration)) { yOffset = topY }
            withAnimation(.easeOut(duration: duration * 0.2).delay(duration * 0.8)) { opacity = 0 }

         
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
       
            ZStack {
                
               
               

           
                AquariumBackgroundView()
                    .environmentObject(aquariumState)

                
              
                BubbleLayerView(topY: aquariumTop, bottomY: aquariumBottom, refreshID: $bubbleRefreshID)
                    .environmentObject(aquariumState).offset(y: 645)

             
                FishMoveView(aquarium: aquarium).opacity(1 - aquariumState.clean).offset(y: -70).scaleEffect(1.6)
                
   
                Rectangle()
                    .cornerRadius(5)
                    .foregroundStyle(.blue)
                    .opacity(0.14)
                    .frame(width: min(UIScreen.main.bounds.width * 2, 2000),
                           height: min(UIScreen.main.bounds.height * 1, 2000))
                    .padding(.top, -58)
                
              
                
         
                    VStack {
                     
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 83).overlay(Color.blue.opacity(0.06)).shadow(color: .black.opacity(0.1), radius: 10)
                    }
                    .edgesIgnoringSafeArea(.bottom).padding(.top, 812)
                
                
                
                
              
            }.background(Color.blue.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    bubbleRefreshID = UUID()
                   
                }
      
    }
}


struct AquariumBackgroundView: View {
    @EnvironmentObject var aquariumState: AquariumState

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
          
                Image("sandfloor")
                    .resizable()
                    .frame(width: min(UIScreen.main.bounds.width * 1.5, 2000),
                           height: min(UIScreen.main.bounds.width * 0.5, 2000))
                    .padding(.top, 520 + ((UIScreen.main.bounds.width - 302) * 0.3))
                    .padding(.horizontal, 50)
                    .opacity(0.95 - (aquariumState.clean * 0.25))

               
                Rectangle()
                    .cornerRadius(5)
                    .foregroundStyle(.green)
                    .opacity(aquariumState.clean)
                    .frame(width: min(UIScreen.main.bounds.width * 2, 2000),
                           height: min(UIScreen.main.bounds.height * 1, 2000))
                    .padding(.top, -58)

   

         // brush
                HStack {
                Spacer()
                    Button {
                        aquariumState.cleanNow()
                    } label: {
                        Image("brush")
                            .resizable()
                            .frame(width: min(UIScreen.main.bounds.width * 0.22, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.22, 700))
                            .opacity(aquariumState.clean > 0 ? min(aquariumState.clean * 2.5, 1) : 0)
                            .animation(.easeInOut(duration: 0.7), value: aquariumState.clean)
                    }
                    .padding(.top, -385)
                    .padding(.horizontal, 395)
                    .disabled(aquariumState.clean <= 0)
                }
            }
        
    }
}


struct BubbleLayerView: View {
    @EnvironmentObject var aquariumState: AquariumState
    let topY: CGFloat
    let bottomY: CGFloat
    @Binding var refreshID: UUID

    var body: some View {
        ForEach(0..<Int(24 * aquariumState.bubbleAmount), id: \.self) { _ in
            BubbleView(topY: topY, bottomY: bottomY)
                .id(refreshID)
                .environmentObject(aquariumState)
        }
    }
}





#Preview {
    AquariumView()
        .environmentObject(AquariumFishList())  .environmentObject(AquariumState())
}

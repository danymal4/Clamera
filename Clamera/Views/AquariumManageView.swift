import SwiftUI



struct AquariumManageView: View {
    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var aquariumState: AquariumState
    @Binding var editState: EditState
    @State var isDropdown: Bool = true
    @State private var viewRefreshID = false
    


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
                ).shadow(color: .black.opacity(0.1), radius: 10)
                .padding(.bottom, -15)

            VStack(alignment: .leading, spacing: 15) {
             
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
                    
                    if !isDropdown {
                        VStack(spacing: 8) {
                            ForEach(aquarium.fish.indices.filter { aquarium.fish[$0].isActive }, id: \.self)  { i in
                               
                            
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
                                    
                                    HStack{
                                        Spacer()
                                        Button{
                                            aquarium.toggleActive(for: fish)
                                            
                                            aquarium.refresh()
                                            
                                            isDropdown = false
                                        }
                                        label: {
                                            Image("X").resizable().frame(
                                                width: min(UIScreen.main.bounds.width * 0.05, 2000),
                                                height: min(UIScreen.main.bounds.width * 0.05, 2000))
                                            
                                        }.padding(.horizontal, 50).padding(.top, -45)
                                        
                                    }

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
                                            
                                            .padding(.horizontal, 15 + (( localScale[safe: i] ?? 50) / 8))
                                          
                                            .scaleEffect(0.5 + (localScale[safe: i] ?? 5) / 15)
                                    
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

                                      
                                        VStack(alignment: .leading, spacing: 5) {
                                      //speed
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

                                            //scale
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
                        .padding(.bottom, CGFloat(aquarium.fish.filter { !$0.isActive }.count) * 100 + 10)


                    }

                 //dropdown
                    if isDropdown {
                        
                     
                        
                        VStack(alignment: .leading, spacing: 40) {
                            HStack {
                                Text("Filter status")
                                Button {} label: {
                                  
                                    if (100 - (300 * aquariumState.clean)) > 60 {
                                         
                                        
                                        Image("good").resizable().frame(
                                            width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                            height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                        )
                                        
                                    }
                                    
                                   else if (100 - (300 * aquariumState.clean)) > 20 {
                                         
                                        
                                        Image("med").resizable().frame(
                                            width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                            height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                        )
                                        
                                    }
                                    
                                    else {
                                        Image("bad").resizable().frame(
                                            width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                            height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                        )
                                        
                                    }
                                }.padding(.horizontal, 20)
                                Text("\(100 - (300 * aquariumState.clean))")
                                    .padding(.horizontal, -25)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.035))
                            }.padding(.top, 25)

                            HStack {
                                Text("Customize")
                               
                                Menu {
                                    
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                      
                                        Slider(
                                            value: $aquariumState.bubbleVisibility,
                                            in: 0...2,
                                            step: 0.1
                                        )
                                        .accentColor(.blue)
                                        .frame(width: UIScreen.main.bounds.width * 0.6)
                                        
                                        Text("Bubble Visibility: \(String(format: "%.2f", aquariumState.bubbleVisibility))")
                                            .font(.system(size: UIScreen.main.bounds.width * 0.035))
                                            .foregroundStyle(.gray)
                                        
                                     
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        
                                        Slider(
                                            value: $aquariumState.bubbleAmount,
                                            in: 0...3,
                                            step: 0.1
                                        )
                                        .accentColor(.blue)
                                        .frame(width: UIScreen.main.bounds.width * 0.6)
                                        
                                        Text("Bubble Amount: \(String(format: "%.2f", aquariumState.bubbleAmount))")
                                            .font(.system(size: UIScreen.main.bounds.width * 0.035))
                                            .foregroundStyle(.gray)
                                        
                                     
                                    }
                                    
                                    
                                    Button(
                                        aquariumState.bubbleVisibility == 0
                                        ? "Remove Bubbles  ✓"
                                        : "Remove Bubbles"
                                    ) {
                                        aquariumState.bubbleVisibility = 0
                                    }
                                    
                                    Button(
                                        aquariumState.bubbleVisibility > 0
                                        ? "Add Bubbles  ✓"
                                        : "Add Bubbles"
                                    ) {
                                        aquariumState.bubbleVisibility = 1
                                    }


                                  
                                
                                } label: {
                                    Image("colorWheel").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.09, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.09, 2000)
                                    )
                                }.padding(.horizontal, 20)
                            }

                            HStack {
                                Text("Clear")
                                Button {
                                    aquarium.toggleAll()
                                } label: {
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

       
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    
  


    func animateRotation(for index: Int) {
        guard index < rotationAngles.count else { return }
        let direction = Bool.random() ? 1.0 : -1.0
        let duration = max(0.3, 2.0 - ((localSpeed[safe: index] ?? 5) / 5))
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            rotationAngles[safe: index] = 10 * direction
        }
    }
}




extension Array {
    subscript(safe index: Int) -> Element? {
        get { indices.contains(index) ? self[index] : nil }
        set { if indices.contains(index), let value = newValue { self[index] = value } }
    }
}


#Preview {
    AquariumManageView(editState: Binding.constant(.editing)) .environmentObject(AquariumFishList()).environmentObject(AquariumState())

}


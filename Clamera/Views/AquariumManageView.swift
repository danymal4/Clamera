import SwiftUI

struct AquariumManageView: View {
    @EnvironmentObject var user: User
    
    @State var isDropdown: Bool = true
    @State private var viewRefreshID = false
    @State private var selectedFish: Int = -1
    @State private var delay: Bool = false
    @State private var refreshID = UUID()
    @State private var swipedIndex: Int? = nil


    var vScale: CGFloat { min(UIScreen.main.bounds.height / 844, 1.2) }

    func speedText(_ value: Double) -> String {
        return "fast"
    }

    func scaleText(_ value: Double) -> String {
        return "large"
    }

    var body: some View {
        
        ZStack(alignment: .top) {

            ScrollView{

                

            
            
                VStack(spacing: 50){
                    ZStack {
                        Rectangle()
                            .opacity(1)
                            .colorInvert()
                            .cornerRadius(30)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                height: min(UIScreen.main.bounds.width * 0.6, 2000)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .padding(.top, -200)
                        
                        VStack{
                            Image("aquariumSetting").resizable() .frame(
                                width: min(UIScreen.main.bounds.width * 0.2, 2000),
                                height: min(UIScreen.main.bounds.width * 0.2, 2000)
                            ).overlay(Color.cyan.opacity(0.15)).cornerRadius(15).padding(.horizontal, -160)           .shadow(color: .black.opacity(0.08), radius: 5)
                            
                            Text("Aquarium").bold() .font(.system(size: UIScreen.main.bounds.width * 0.06)).frame(
                                width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                alignment: .leading
                            )
                            
                            
                            Text("Personalize your very own aquarium adjusting your fish, bubble settings, and considering the filter options").opacity(0.5).font(.system(size: UIScreen.main.bounds.width * 0.045)).frame(
                                width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                alignment: .leading
                            )
                            
                        }.padding(.top, -200).padding(.horizontal, -165)
                        
                    }.padding(.top, 230)
                    
                    
                    
                    
                    
                    let collapsedHeight = min(UIScreen.main.bounds.width * 0.43, 2000)
                    let expandedHeight = min(UIScreen.main.bounds.width * 0.6, 2000)

                    ZStack {

                        // 🔵 BACKGROUND RECTANGLE (big white box)
                        Rectangle()
                            .opacity(1)
                            .colorInvert()
                            .cornerRadius(30)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                height: isDropdown ? collapsedHeight : expandedHeight + 10
                            )
                            .animation(.easeInOut(duration: 0.3), value: isDropdown)
                            .shadow(color: .black.opacity(0.1), radius: 10)

                        // Header
                        HStack {
                            Text("Fish")
                                .opacity(0.5)
                                .font(.system(size: UIScreen.main.bounds.width * 0.045))
                                .bold()
                                .offset(y: isDropdown ? 0 : -0.5 * UIScreen.main.bounds.width * 0.15 - 9.5)
                            Spacer()
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, -110)

                        // Fish rows
                        VStack(spacing: 14.5) {
                            ForEach(Array(user.aquarium.fish.enumerated()), id: \.element.id) { i, fish in

                                VStack(spacing: 5) {
                                    // Fish row: icon + toggle + divider
                                    HStack {
                                        Spacer().frame(width: 180)

                                        if fish.isActive {
                                            Image(fish.imageName)
                                                .resizable()
                                                .frame(
                                                    width: min(UIScreen.main.bounds.width * 0.1, 180),
                                                    height: min(UIScreen.main.bounds.width * 0.1, 180)
                                                )
                                                .opacity(fish.isShown ? 0.9 : 0.4)
                                                .offset(x: swipedIndex == i ? 70 : 0)

                                            if fish.isShown {
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        swipedIndex = nil
                                                        if selectedFish != i && !isDropdown {
                                                            selectedFish = i
                                                        } else {
                                                            selectedFish = i
                                                            isDropdown.toggle()
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "chevron.down")
                                                        .foregroundStyle(.black)
                                                        .frame(width: 24, height: 24)
                                                        .rotationEffect(.degrees(selectedFish == i && !isDropdown ? 180 : 0))
                                                        .animation(.easeInOut(duration: 0.3), value: isDropdown)
                                                }
                                                .buttonStyle(.plain)
                                                .offset(x: swipedIndex == i ? 70 : 0)
                                            } else {
                                                Image(systemName: "chevron.down")
                                                    .foregroundStyle(.black)
                                                    .frame(width: 24, height: 24)
                                                    .opacity(0)
                                                    .offset(x: swipedIndex == i ? 70 : 0)
                                            }
                                        } else {
                                            Image("FishIcon")
                                                .resizable()
                                                .frame(
                                                    width: min(UIScreen.main.bounds.width * 0.1, 1800),
                                                    height: min(UIScreen.main.bounds.width * 0.1, 1800)
                                                )
                                                .opacity(0.9)
                                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                                .offset(x: swipedIndex == i ? 70 : 0)
                                        }

                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        Spacer()

                                        if fish.isActive {
                                            Toggle("", isOn: Binding(
                                                get: { fish.isShown },
                                                set: { newValue in
                                                    let updatedFish = fish
                                                    updatedFish.isShown = newValue
                                                    user.aquarium.fish[i] = updatedFish
                                                    
                                                    if i == selectedFish && !isDropdown {
                                                        isDropdown.toggle()
                                                    }
                                                }
                                            ))
                                            .labelsHidden()   .tint(.green)
                                        }
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        Spacer()

                                    }
                                    .padding(.horizontal, -210)
                                    .offset(y: isDropdown
                                            ? 0
                                            : (i <= selectedFish
                                               ? 0.5 * UIScreen.main.bounds.width * 0.04
                                               : -0.5 * UIScreen.main.bounds.width * 0.04))
                                    .animation(.easeInOut(duration: 0.3), value: isDropdown)

                                    Divider()
                                        .frame(width: min(UIScreen.main.bounds.width * 0.85, 1800))
                                        .offset(y: isDropdown
                                                ? 0
                                                : (i <= selectedFish
                                                   ? 0.5 * UIScreen.main.bounds.width * 0.04
                                                   : -0.5 * UIScreen.main.bounds.width * 0.04))
                                        .animation(.easeInOut(duration: 0.3), value: isDropdown)
                                        .opacity(i == 2 || (i == selectedFish && !isDropdown) ? 0 : 1)
                                        .offset(x: swipedIndex == i ? 70 : 0)

                                    // Sliders
                                    if !isDropdown && i == selectedFish {
                                        VStack(spacing: 10) {
                                            HStack {
                                                Image("slow").resizable().frame(
                                                    width: min(UIScreen.main.bounds.width * 0.06, 2000),
                                                    height: min(UIScreen.main.bounds.width * 0.06, 2000)
                                                )
                                                Slider(
                                                    value: Binding(
                                                        get: { 16 - fish.swimDuration },
                                                        set: { newVal in
                                                            user.aquarium.updateSpeed(for: fish, to: 16 - newVal)
                                                        }
                                                    ),
                                                    in: 1...15
                                                ).accentColor(.cyan.opacity(0.6))

                                                Image("fast").resizable().frame(
                                                    width: min(UIScreen.main.bounds.width * 0.06, 2000),
                                                    height: min(UIScreen.main.bounds.width * 0.06, 2000)
                                                )
                                            }

                                            HStack {
                                                Image("small").resizable().frame(
                                                    width: min(UIScreen.main.bounds.width * 0.065, 2000),
                                                    height: min(UIScreen.main.bounds.width * 0.065, 2000)
                                                )
                                                Slider(
                                                    value: Binding(
                                                        get: { Double(fish.size.width) },
                                                        set: { newVal in
                                                            let newHeight = fish.size.height * newVal / fish.size.width
                                                            user.aquarium.updateSize(for: fish, to: CGSize(width: newVal, height: newHeight))
                                                        }
                                                    ),
                                                    in: 20...200
                                                ).accentColor(.cyan.opacity(0.6))

                                                Image("big").resizable().frame(
                                                    width: min(UIScreen.main.bounds.width * 0.08, 2000),
                                                    height: min(UIScreen.main.bounds.width * 0.1, 2000)
                                                )
                                            }
                                            Divider()
                                                .frame(width: min(UIScreen.main.bounds.width * 0.85, 2000))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                }
                                .contentShape(Rectangle())
                                .background(
                                    HStack {
                                        Spacer()

                                        Button {
                                            if fish.isActive {
                                                withAnimation(.easeInOut) {
                                                    if let speciesID = fish.speciesID,
                                                       let species = user.speciesStore.speciesList.first(where: { $0.id == speciesID }) {
                                                        
                                                        if let fishToRemove = species.fishList.first(where: { $0.isAquarium }) {
                                                            fishToRemove.isAquarium = false
                                                        }
                                                    }
                                                    user.aquarium.removeFish(with: fish.imageName, targetSize: fish.size)
                                                    swipedIndex = nil
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.white)
                                                .frame(width: 70, height: 61)
                                                .background(Color.red)
                                                .cornerRadius(5).opacity(fish.isActive ? 1 : 0)
                                        }
                                        .padding(.top, -13.5)
                                        .offset(x: swipedIndex == i ? 90 : 90)
                                        .animation(.easeInOut(duration: 0.25), value: swipedIndex)
                                    }
                                )
                                .offset(x: swipedIndex == i ? -70 : 0)
                                .highPriorityGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            guard isDropdown else { return }

                                            if value.translation.width < -30 {
                                                withAnimation(.easeOut) { swipedIndex = i }
                                            }

                                            if value.translation.width > 30 {
                                                withAnimation(.easeOut) { swipedIndex = nil }
                                            }
                                        }
                                )
                                .padding(.horizontal, 60)
                            }
                        }
                        .padding(.bottom, -10)  .frame(
                            width: min(UIScreen.main.bounds.width * 0.9, 2000),
                            height: isDropdown ? collapsedHeight : expandedHeight
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    
                 
                    .animation(.easeInOut(duration: 0.3), value: isDropdown)
                  
                    
                    // filter box
                    
                    
                    ZStack{
                        
                        
                        
                        
                        Rectangle()
                            .opacity(1)
                            .colorInvert()
                            .cornerRadius(30)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                height: min(UIScreen.main.bounds.width * 0.3, 2000)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10)
                        
                        HStack{
                            
                            Text("Filter").opacity(0.5).font(.system(size: UIScreen.main.bounds.width * 0.045)).bold()
                                .padding(.top, -85)
                            
                            Spacer()
                            
                        }.padding(.horizontal, 45)
                        
                        
                        VStack(spacing: 6) {
                            
                            HStack {
                                
                                
                                if (100 - (300 * user.aquariumState.clean)) > 60 {
                                    Image("good").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                    )
                                } else if (100 - (300 * user.aquariumState.clean)) > 20 {
                                    Image("med").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                    )
                                } else {
                                    Image("bad").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                    )
                                    
                                }
                                
                                
                                Text("Status").font(.system(size: UIScreen.main.bounds.width * 0.045)).opacity(0.9)
                                
                                Spacer()
                                
                                
                                
                                Text("  \(String(format: "%.2f", (100 - (300 * user.aquariumState.clean)))) %")
                                    .padding(.horizontal, -5)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.035))
                                    .padding(.horizontal, 10)
                                
                                
                            }.padding(.horizontal, 40)
                            
                            
                            Divider()
                                .frame(width: min(UIScreen.main.bounds.width * 0.85, 1800))
                            
                            
                            HStack {
                                
                                
                                
                                    Image("level").resizable().frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 2000)
                                    )
                               
                                Text("Level").font(.system(size: UIScreen.main.bounds.width * 0.045)).opacity(0.9)
                                
                                Spacer()
                                
                                
                                
                                Text("4")
                                    .padding(.horizontal, 10)
                                
                                
                            }.padding(.horizontal, 40)
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                    // bubbles
                    ZStack{
                        
                        Rectangle()
                            .opacity(1)
                            .colorInvert()
                            .cornerRadius(30)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                height: min(UIScreen.main.bounds.width * 0.45, 2000)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10)
                        
                        
                    
                        
                        
                        VStack(spacing: 8){
                           
                            
                            
                            HStack{
                                
                                Text("Bubbles").opacity(0.5).font(.system(size: UIScreen.main.bounds.width * 0.045)).bold()
                                 
                                
                                Spacer()
                                
                                Toggle("Bubbles", isOn: Binding(
                                    get: { user.aquariumState.bubbleVisibility > 0 },
                                    set: { newValue in
                                        user.aquariumState.bubbleVisibility = newValue ? 1 : 0
                                    }
                                ))
                                .labelsHidden().tint(.green)
                                
                            }.padding(.horizontal, 45)
                            
                            
                            Divider()
                                .frame(width: min(UIScreen.main.bounds.width * 0.85, 1800))
                            
                            
                            HStack{
                              
                                Spacer()
                                
                                Image("bubbleIcon").resizable().frame(
                                    width: min(UIScreen.main.bounds.width * 0.1, 2000),
                                    height: min(UIScreen.main.bounds.width * 0.1, 2000)).cornerRadius(10).padding(.horizontal, -40)
                                
                                
                                Text("Amount  \(String(format: "%.1f", user.aquariumState.bubbleAmount))").opacity(0.9).opacity(0.5)
                                
                                Spacer()
                            
                                
                                Stepper("", value: $user.aquariumState.bubbleAmount, in: 0.1...3, step: 0.1)
                                       .labelsHidden()
                                       .frame(width: UIScreen.main.bounds.width * 0.6).padding(.horizontal, -40)
                           
                            }
                            
                            Divider()
                                .frame(width: min(UIScreen.main.bounds.width * 0.85, 1800))
                            
                            HStack{
                                Spacer()
                                Image("visibility").resizable().frame(
                                    width: min(UIScreen.main.bounds.width * 0.1, 2000),
                                    height: min(UIScreen.main.bounds.width * 0.1, 2000)).colorInvert().cornerRadius(10).padding(.horizontal, -40)
                                
                                Text("Visibility  \(String(format: "%.1f", user.aquariumState.bubbleVisibility))").opacity(0.9).opacity(0.5)
                           
                                Spacer()
                                
                                
                                Stepper("", value: $user.aquariumState.bubbleVisibility, in: 0.1...2, step: 0.1)
                                       .labelsHidden()
                                .frame(width: UIScreen.main.bounds.width * 0.6).padding(.horizontal, -40)
                                
                                
                            }
                            
                        }
                        
                    
                    }
                    
                    
                    ZStack{
                        
 

                        Button {
                            user.aquarium.toggleAll()               // your existing logic
                            refreshID = UUID()                  // triggers SwiftUI to re-render the view
                        } label: {
                            Rectangle()
                                .opacity(1)
                                .foregroundStyle(Color.white)
                                .cornerRadius(30)
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                    height: min(UIScreen.main.bounds.width * 0.15, 2000)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        }
                        .id(refreshID)   // <-- forces this view (and its subtree) to refresh
                        
                        HStack{
                            Text("Clear Aquarium").foregroundStyle(.red)
                            Spacer()
                        }.padding(.horizontal, 40)
                    }.padding(.top, -10)
                    
                    
                }
            }

    
        }
        .background(Color(.systemBackground)) .onAppear {
            user.aquariumState.markActive("manage")
        }
        .onDisappear {
            user.aquariumState.updatePendingClean(to: user.aquariumState.clean)

            user.aquariumState.markInactive("manage")
            
       
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
    AquariumManageView()
        .environmentObject(User())

}


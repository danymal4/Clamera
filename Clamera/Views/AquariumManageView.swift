import SwiftUI

struct AquariumManageView: View {
    @Binding var editState: EditState
    @State var speed: Double = 5
    @State var scale: Double = 5
    @State var isDropdown: Bool = false

    // scale factor (so spacing grows slightly on larger screens)
    var vScale: CGFloat { min(UIScreen.main.bounds.height / 844, 1.2) }

    var body: some View {
        ZStack {

            // MARK: - Background
          
            WaterView().offset(y: -300)
            
            WaterView().offset(y: -700)
            WaterView().offset(y: 200)
            
            WaterView().offset(y: 300)
            WaterView().offset(y: 300).opacity(0.5)
            
          
            Image("ripples").resizable() .frame(
                width: min(UIScreen.main.bounds.width * 1, 2000),
                height: min(UIScreen.main.bounds.width * 2.1, 2000)
            ).opacity(0.03)
            
            IconView().padding(.top, 40)

            // MARK: - Back Button
            VStack {
                HStack {
                    Button {
                        editState = .notEditing
                    } label: {
                        Text("< back")
                    }
                    Spacer()
                }
                .padding().padding(.top, 40)
                

                Spacer()
            }

         

            // MARK: - Big Clear Rectangle
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

            // MARK: - Content inside rectangle
            VStack(alignment: .leading, spacing: 15) {

                // Fish Label + Dropdown Button (always visible)
                HStack {
                    Text("Fish")
                          // small downward shift if needed
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


                // MARK: - Replaceable Content
                ZStack {

                    // Fish Icons + Sliders
                    if !isDropdown {
                        VStack(spacing: 8) {
                            ForEach(0..<3) { i in
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
                                        Button{
                                            
                                        }
                                        label: {
                                           
                                            Spacer()
                                            Image("remove").resizable()
                                                .frame(
                                                    width: min(UIScreen.main.bounds.width * 0.05, 180),
                                                    height: min(UIScreen.main.bounds.width * 0.05, 180)
                                                )
                                                .opacity(0.9)
                                                .padding(.horizontal, 45).padding(.bottom, 65)
                                      
                                        }
                                        }

                                    HStack {
                                        let fishImages = ["puffer", "clownFish", "grouper"]
                                        Image(fishImages[i])
                                            .resizable()
                                            .frame(
                                                width: min(UIScreen.main.bounds.width * 0.13, 180),
                                                height: min(UIScreen.main.bounds.width * 0.13, 180)
                                            )
                                            .opacity(0.9)
                                            .background(
                                                Circle().colorInvert().opacity(0.5)
                                            )

                                        VStack {
                                            Slider(value: $speed, in: 1...10)
                                            Slider(value: $scale, in: 1...10)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 60)
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                        .transition(.opacity).padding(.bottom, 20)
                    }

                    // Dropdown Menu
                    if isDropdown {
                        VStack(alignment: .leading, spacing: 40) {

                            Text("Filter status").padding(.top, 25)
                            Text("Customize")
                            Text("Clear")

                            // Invisible layout spacer
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 20 * vScale) // tweak this to adjust spacing up/down

                        }
                        .padding(.horizontal, 60)
                        .transition(
                            .move(edge: .top).combined(with: .opacity)
                        )
                    }
                }

            }
          

            // MARK: - Bottom White Bar
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


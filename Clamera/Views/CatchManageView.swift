//
//  CatchManageView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/7/26.
//

import SwiftUI


struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


struct CatchManageView: View {
    
    @Binding var editState: EditState
    @State var info = ""
    @State var species = ""
    
    var body: some View {
     
        ZStack {
            
            WaterView().offset(y: -300)
            
            WaterView().offset(y: -700)
            WaterView().offset(y: 200)
            
            WaterView().offset(y: 300)
            WaterView().offset(y: 300)
            
            
            
            
            // Blur layer
            BlurView(style: .systemUltraThinMaterial)
                .ignoresSafeArea()
            
            Image("fishies").resizable().opacity(0.03)
            
            HStack{
                Button {
                    editState = .notEditing
                } label: {
                    Text("< cancel")
                }
                Spacer()
            }.padding(.bottom, 730).padding()
            IconView()
            
            
            Rectangle()
                .cornerRadius(40)
                .foregroundStyle(.white)
                .opacity(0.3)
                .frame(
                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                    height: min(UIScreen.main.bounds.width * 0.8, 5000)
                )
            
            Rectangle()
                .cornerRadius(30)
                .foregroundStyle(.white)
                .opacity(0.4)
                .frame(
                    width: min(UIScreen.main.bounds.width * 0.75, 2000),
                    height: min(UIScreen.main.bounds.width * 0.75, 5000)
                )
            
            
            
            
            VStack {
                
                
                
                Text("Description").font(.system(size: UIScreen.main.bounds.width * 0.05))
                    .bold().opacity(0.9)
                
                
                ZStack{
                    TextField("Enter text", text: $info)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 55).foregroundStyle(.blue)
                }
                
                
                Text("Species").font(.system(size: UIScreen.main.bounds.width * 0.05))
                    .padding(.top, 46).bold().opacity(0.9)
                
                
                
                TextField("Enter text", text: $species)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 55).padding(.bottom, 35).foregroundStyle(.blue)
                
                
                
                HStack{
                    Spacer()
                    Button("Confirm") {
                        editState = .notEditing
                    }.padding(.horizontal, 67)
                        .buttonStyle(.borderedProminent).opacity(0.9)
                    
                    
                }
                
                
                
                
            }.padding(.top, 30)
       
            
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
    CatchManageView(editState: Binding.constant(.editing))
}

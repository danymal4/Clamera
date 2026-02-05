//
//  AquariumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

enum EditState{
    case editing, notEditing
}
struct AquariumView: View {
   
    
    @State var editState: EditState = .notEditing
    
    var body: some View {
        
        if editState == .notEditing {
            
            ZStack {
                
                IconView()
                
                VStack {
                    Text("Aquarium")
                        .font(.custom(
                            "IslandMoments-Regular",
                            size: UIScreen.main.bounds.width * 0.3
                        ))
                        .opacity(0.9)
                        .foregroundStyle(.blue)
                    
                    Image("Aquarium")
                        .resizable()
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.7, 2000),
                            height: min(UIScreen.main.bounds.width * 0.8, 700)
                        )
                        .padding(.bottom, 65)
                        .scaleEffect(1.45)
                }
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .cornerRadius(30)
                            .colorInvert()
                            .opacity(0.3)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                height: min(UIScreen.main.bounds.width * 0.2, 90)
                            )
                        Button{
                            editState = .editing
                        }
                        label:{
                            Text("Manage")
                                .font(.system(size: UIScreen.main.bounds.width * 0.07)).foregroundStyle(.black)
                                .opacity(0.8)
                                .bold()
                        }
                    }
                    .padding(.bottom, 40)
                        
                        
                    
                    Rectangle()
                    
                        .colorInvert().opacity(0.6)
                        .frame(
                            width: min(UIScreen.main.bounds.width * 1, 2000),
                            height: min(UIScreen.main.bounds.width * 0.205, 90)
                        ).padding(.bottom, -330)
                    
                    
                }
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                
                WaterView()
                    .frame(height: UIScreen.main.bounds.height + 400)
                    .offset(y: -150) // same visual you had
                    .allowsHitTesting(false)
                
            )
            
        }
        else {
            AquariumManageView(editState: $editState)
            }
            
            
        
    }
}

#Preview {
    AquariumView()
}


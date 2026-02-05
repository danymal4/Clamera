//
//  AquariumManageView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct AquariumManageView: View {
    @Binding var editState: EditState
    
    var body: some View {
      
        IconView()
        
        HStack{
            Button {
                editState = .notEditing
            } label: {
                Text("<")
            }
            Spacer()
        }.padding().padding(.top, -190)
        ZStack{
          
            
            
           
            
            
           
            WaterView().offset(y: -550)
            VStack{
                Text("Manage")
                    .font(.custom(
                        "IslandMoments-Regular",
                        size: UIScreen.main.bounds.width * 0.3
                    ))
                    .opacity(0.9)
                    .foregroundStyle(.blue).padding(.top, -620)
                
            }
        }.padding(.bottom, -4000)
     
        Rectangle().opacity(0.8).colorInvert().cornerRadius(90).opacity(0.3).frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                                                                   height: min(UIScreen.main.bounds.width * 0.9, 2000))
        
        
        VStack {
                      Spacer()
                      Rectangle()
                          .fill(Color.white.opacity(0.6))
                          .frame(height: 83)
                           // or safeAreaInset if you want
                  }
              
              .edgesIgnoringSafeArea(.bottom)
        
    }
}

#Preview {
    AquariumManageView(editState: Binding.constant(.editing))
}

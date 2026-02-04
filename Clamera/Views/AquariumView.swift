//
//  AquariumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

struct AquariumView: View {
    var body: some View {
    
        
      
        ZStack{
         
            
            WaterView().offset(y: -150)
            IconView()
          
            VStack{
                Text("Aquarium").font(.custom("IslandMoments-Regular",  size: UIScreen.main.bounds.width * 0.3)).opacity(0.9).foregroundStyle(.blue)
               
                    Image("Aquarium").resizable().frame(width: min(UIScreen.main.bounds.width * 0.7, 2000),
                                                        height: min(UIScreen.main.bounds.width * 0.8, 700)).padding(.bottom, 40).scaleEffect(1.45)
      
          
            }
          
            
            ZStack{
                VStack{
                  Spacer()
                    ZStack{
                        Rectangle().cornerRadius(30).colorInvert().opacity(0.3).frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                                                                      height: min(UIScreen.main.bounds.width * 0.2, 90)).padding(.bottom, 40)
                        
                        Text("Manage").padding(.bottom, 40).font(.system(size: UIScreen.main.bounds.width * 0.07)).opacity(0.8).bold()
                        
                        
                    }
               
                
                }
            }

            }
            
            
        
    }
}

#Preview {
    AquariumView()
}

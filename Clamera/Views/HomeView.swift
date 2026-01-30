//
//  HomeView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Hello, World!")
  
        
        ZStack{
            Image("waves").opacity(0.7)
            HStack{
              
            }
          
            VStack{
                Spacer()
                Spacer()
                Spacer()
                Rectangle().frame(width: 300, height: 5).opacity(0.8)
                
                ZStack{
                    Rectangle().frame(width: 140, height: 20).opacity(0.8).colorInvert().cornerRadius(90).opacity(0.38)
                    Text("Recent Catches")
                   
                }
                Spacer()
                Spacer()
                
            }
            
        }
        
        
        
    }
}

#Preview {
    HomeView()
}

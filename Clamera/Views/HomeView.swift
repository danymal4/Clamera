//
//  HomeView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
 
       
        ZStack{
            
            WaterView().opacity(0.49)
                .offset(y: -300)
            
         
            
        
        
          
            VStack{
                Spacer()
                Spacer()
                Spacer()
                Rectangle().frame(width: 300, height: 5).opacity(0.6)
                
                ZStack{
                    Rectangle().frame(width: 140, height: 20).opacity(0.8).colorInvert().cornerRadius(90).opacity(0.38)
                    Text("Recent Catches")
                    
                   
                }
              
      
                HStack{
                    Spacer()
                    Spacer()
                    Spacer()
                  
                    //make a button
                    
                 
                    
                    Image("PictureFish").resizable().aspectRatio(contentMode: .fit).cornerRadius(30)
                    
                    
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
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

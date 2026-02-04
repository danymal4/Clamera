//
//  LogInView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 2/3/26.
//

import SwiftUI

struct LogInView: View {
    var body: some View {
       
        
        ZStack{
            WaterView()
                .position(x:201, y: 400)
                
            HStack {
                
                VStack{
                 
                        
                    
                 
                    
                    
                    
                    ZStack {
                        Text("Clamera")
                            .font(.custom("IslandMoments-Regular", size: 70))
                            .bold()
                            .foregroundStyle(Color.clameraBlue)
                        Text("<")
                            .padding(.trailing, 300)
                            .font(.custom("IslandMoments-Regular", size: 70))
                        
                    }
                    
                    
                    
                    
                    HStack {
                        Text("Login info ")
                            .font(.custom("HelveticaNeue-Thin", size: 25))
                            .bold()
                        
                    }
                    HStack{
                        Text("Email")
                            .font(.custom("HelveticaNeue-Thin", size: 20))
                            .bold()
                    }
                    
                    
                    HStack{
                        Rectangle()
                            .frame(width: 250, height: 40)
                            .foregroundStyle(Color.clameraBlue.opacity(0.5))
                            .cornerRadius(20)
                    }
                    
                    
                    HStack{
                        Text("Password")
                            .font(.custom("HelveticaNeue-Thin", size: 20))
                            .bold()
                    }
                    
                    
                    HStack{
                        Rectangle()
                            .frame(width: 250, height: 40)
                            .foregroundStyle(Color.clameraBlue.opacity(0.5))
                            .cornerRadius(20)
                        
                    }
                   
                    
                    ZStack{
                        Rectangle()
                            .frame(width: 200, height: 40)
                            .foregroundStyle(Color.clameraBlue)
                            .cornerRadius(20)
                        Text("Continue")
                            .font(.custom("HelveticaNeue-Thin", size: 15))
                            .foregroundStyle(Color.white)
                            .bold()
                            
                            
                         
                            
                        
                    }
                    
                    
                    
                }
                
                
                
            }
            .position(x: 200, y: 200)
            
            
            
            
        }
        
        }
    }




#Preview {
    LogInView()
}

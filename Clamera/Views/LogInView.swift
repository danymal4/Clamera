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
            IconView()
            
            WaterView()
            HStack {
                
                VStack{
                    HStack{
                        Text("<")
                    }
                    
                    
                    
                    HStack {
                        Text("Clamera")
                            .font(.custom("IslandMoments-Regular", size: 70))
                            .bold()
                            .foregroundStyle(Color.clameraBlue)
                        
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
                    
                    
                }
                
            }
            
            
            
            
        }
        
        }
    }




#Preview {
    LogInView()
}

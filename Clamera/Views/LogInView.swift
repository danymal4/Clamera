//
//  LogInView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 2/3/26.
//

import SwiftUI

struct LogInView: View {
    var body: some View{
        
        WaterView()
            .position(x: 200, y: 480)
        
        HStack {
            
            VStack{
                HStack {
                    Text("Clamera")
                        .font(.custom("IslandMoments-Regular", size: 90))
                        .foregroundStyle(.blue)
                    
                }.position(x: 200, y: 40)
                HStack {
                    Text("Log In")
                        .font(.custom("HelveticaNeue-Thin", size: 20))
                        .bold()
                    
                }.position(x: 200,y:50)
                HStack {
                    Text("Enter your email and password to log in")
                        .font(.custom("HelveticaNeue-Thin", size: 18))
                    
                } .position(x: 200, y:20)
                
            }
            
            
        } .position(x:200, y:-40)
        
        ZStack{
            Text("<")
                .font(.custom("HelveticaNeue-Thin", size: 40))
                .bold()
                .position(x: 40, y: -160)
                
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
                
            Text("email@​domain.com")
                .foregroundStyle(.gray)
                .bold()
                .padding(.trailing, 170)
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
                .position(x: 200, y:160)
                
            Text("Password123")
                .foregroundStyle(.gray)
                .bold()
                .padding(.trailing, 220)
                .position(x: 200, y:160)
            
        }.position(x: 200, y: -120)
        
        
        
        ZStack{
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-185)
            
            
            Text("Continue")
                .foregroundStyle(.white)
                .bold()
                .position(x: 200, y:-185)
            
        }
    }
    }
#Preview {
    LogInView()
}

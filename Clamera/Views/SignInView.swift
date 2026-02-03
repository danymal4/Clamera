//
//  SignInView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct SignInView: View {
    var body: some View{

        WaterView()
            .offset(y: 200)
            
        HStack {
            
            VStack{
                HStack {
                    Text("Clamera")
                        .font(.custom("IslandMoments-Regular", size: 90))
                        .foregroundStyle(.blue)
                    
                }
                HStack {
                    Text("Create an account")
                        .font(.custom("HelveticaNeue-Thin", size: 20))
                        .bold()
                    
                }.offset(y: 18)
                HStack {
                    Text("Enter your email to sign up for this app")
                        .font(.custom("HelveticaNeue-Thin", size: 18))
                    
                } .offset(y: 20)
                
            }
            
            
        } .offset(y:-700)
        
        ZStack{
            Rectangle()
                .foregroundStyle(.white)
                
                .frame(width: 350, height: 50)
                .cornerRadius(10)
            
            
            Text("Continue")
                .foregroundStyle(.gray)
                .bold()
        }.offset(y:-670)
        
        ZStack{
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
            
            
            Text("Continue")
                .foregroundStyle(.white)
                .bold()
        }.offset(y:-660)
        
        }
    }



#Preview {
    SignInView()
}

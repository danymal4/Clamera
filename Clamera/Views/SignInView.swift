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
            .position(x: 200, y: 650)
        
        HStack {
            
            VStack{
                HStack {
                    Text("Clamera")
                        .font(.custom("IslandMoments-Regular", size: 90))
                        .foregroundStyle(.blue)
                    
                }.position(x: 200, y: 40)
                HStack {
                    Text("Create an account")
                        .font(.custom("HelveticaNeue-Thin", size: 20))
                        .bold()
                    
                }.position(x: 200,y:50)
                HStack {
                    Text("Enter your email to sign up for this app")
                        .font(.custom("HelveticaNeue-Thin", size: 18))
                    
                } .position(x: 200, y:20)
                
            }
            
            
        } .position(x:200, y:-40)
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
                
            Text("email@​domain.com")
                .foregroundStyle(.gray)
                .bold()
                .padding(.trailing, 170)
        }.position(x: 200, y: -120)
        
        ZStack{
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-250)
            
            
            Text("Continue")
                .foregroundStyle(.white)
                .bold()
                .position(x: 200, y:-250)
            
            Rectangle()
                .foregroundStyle(.gray)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-150)
            
            Text("⎯⎯⎯⎯⎯⎯⎯⎯      or      ⎯⎯⎯⎯⎯⎯⎯⎯")
                .foregroundStyle(.gray)
                .bold()
                .position(x: 200, y:-200)
            
            
            Text("Continue With Google")
                .foregroundStyle(.white)
                .bold()
                .position(x: 200, y:-150)
            
            Rectangle()
                .foregroundStyle(.gray)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-90)
            
            
            Text("Continue With Apple")
                .foregroundStyle(.white)
                .bold()
                .position(x: 200, y:-90)
            
            Text("By clicking continue, you agree to our Terms of Service and Privacy Policy")
                .foregroundStyle(.gray)
                .bold()
                .font(.custom("HelveticaNeue-Thin", size: 14))
                .padding(.leading, 40)
                .padding(.trailing, 40)
                .position(x: 200, y: -18)
            
        }

    }
}



#Preview {
    SignInView()
}

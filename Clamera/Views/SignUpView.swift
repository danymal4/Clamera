//
//  SignInView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct SignUpView: View {
    
    @State var email = ""
    @State var password = ""
    @State var username = ""
    
    var body: some View{
        
        WaterView()
            .position(x: 200, y: 650).opacity(0.6)
        
        HStack {
            VStack{
                HStack {
                    Text("Clamera")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)
                        .shadow(color: .black.opacity(0.08), radius: 2, x: 1, y: 1)
                    
                }.position(x: 200, y: 40)
                HStack {
                    Text("Create an account")
                        .font(.custom("HelveticaNeue-Thin", size: 20))
                        .bold()
                    
                }.position(x: 200,y:60)
                HStack {
                    Text("Enter your email and password to sign up for this app")
                        .font(.custom("HelveticaNeue-Thin", size: 18))
                    
                } .position(x: 200, y:45)
                
            }
            
            
        } .position(x:200, y:-40)
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
                
            TextField("username", text: $username)
                .foregroundStyle(.gray)
                .bold()
                .padding(.leading, 40)
        }.position(x: 200, y: -40)
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
                
            TextField("email@​domain.com", text: $email)
                .foregroundStyle(.gray)
                .bold()
                .padding(.leading, 40)
        }.position(x: 200, y: -110)
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
                
            SecureField("Password", text: $password)
                .foregroundStyle(.gray)
                .bold()
                .padding(.leading, 40)
        }.position(x: 200, y: -180)
        
        ZStack{
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-250)
            
            
            Button("Sign up"){
                Task{
                    await AuthManager.shared.signUp(username: username, email: email, password: password)
                }
            }
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
            
            
            Text("Sign In With Username & Password")
                .foregroundStyle(.white)
                .bold()
                .position(x: 200, y:-150)
            
            Rectangle()
                .foregroundStyle(.gray)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-90)
            
            
            Text("Continue With Google")
                .foregroundStyle(.white)
                .bold()
                .position(x: 200, y:-90)
            
            
            Text("By clicking continue, you agree to our Terms of Service and Privacy Policy")
                .foregroundStyle(.gray)
                .bold()
                .font(.custom("HelveticaNeue-Thin", size: 14))
                .padding(.leading, 40)
                .padding(.trailing, 40)
                .position(x: 200, y: -30)
            
        }

    }
}



#Preview {
    SignUpView()
}

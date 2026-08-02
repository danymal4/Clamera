//
//  LogInView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 2/3/26.
//

import SwiftUI

struct SignInView: View {
    
    @State var email = ""
    @State var password = ""
    @State var username = ""
    @Binding var editState: EditState
    
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
                    Text("Sign In To Your Account")
                        .font(.custom("HelveticaNeue-Thin", size: 20))
                        .bold()
                    
                }.position(x: 200,y:70)
            }
            
            
        } .position(x:200, y:-40)
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
            
            TextField("Username or Email", text: $email)
                .foregroundStyle(.gray)
                .bold()
                .padding(.leading, 40)
        }.position(x: 200, y: -65)
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .foregroundStyle(.white)
                .frame(width: 350, height: 50)
            
            SecureField("Password", text: $password)
                .foregroundStyle(.gray)
                .bold()
                .padding(.leading, 40)
        }.position(x: 200, y: -160)
        
        ZStack{
            // --- SIGN IN BUTTON ---
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-250)
            
            Button("Sign In"){
                Task{
                    await AuthManager.shared.signIn(loginInput: email, password: password)
                }
            }
            .foregroundStyle(.white)
            .bold()
            .position(x: 200, y:-250)
            
            // --- CONTINUE WITH GOOGLE ---
            Rectangle()
                .foregroundStyle(.gray)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-190)
            
            Button("Continue With Google") {
                Task {
                    do {
                        try await AuthManager.shared.signInWithGoogle()
                    } catch {
                        print("Google Sign-In failed: \(error.localizedDescription)")
                    }
                }
            }
            .foregroundStyle(.white)
            .bold()
            .position(x: 200, y:-190)
            
            // --- DIVIDER TEXT ---
            Text("⎯⎯⎯    Don't have an account?      ⎯⎯")
                .foregroundStyle(.gray)
                .bold()
                .position(x: 200, y:-130)
            
            // --- SIGN UP BUTTON ---
            Rectangle()
                .foregroundStyle(.gray)
                .frame(width: 350, height: 50)
                .cornerRadius(10)
                .position(x: 200, y:-80)
            
            Button("Sign Up With Email and Password"){
                editState = .notEditing
            }
            .foregroundStyle(.white)
            .bold()
            .position(x: 200, y:-80)
            
        }
    }
}

#Preview {
    SignInView(editState: Binding.constant(.editing))
}

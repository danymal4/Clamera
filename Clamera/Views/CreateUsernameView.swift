//
//  CreateUsernameView.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/1/26.
//
import SwiftUI

struct CreateUsernameView: View {
    @State private var newUsername = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Welcome to Clamera!")
                .font(.largeTitle)
                .bold()
            
            Text("Please choose a username so your friends can find you.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter Username", text: $newUsername)
                .autocapitalization(.none) // Keep it lowercase-friendly
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await AuthManager.shared.finalizeGoogleSignUp(chosenUsername: newUsername)
                }
            } label: {
                Text("Complete Sign Up")
                    .bold()
                    .foregroundStyle(.white)
                    .frame(width: 250, height: 50)
                    .background(newUsername.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(newUsername.isEmpty) // Prevent them from submitting a blank name
        }
    }
}
#Preview {
    CreateUsernameView()
}

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
        ZStack {
            // MARK: - Background Element
            VStack {
                Spacer()
                WaterView()
                    .frame(height: 200)
                    .opacity(0.6)
                    .ignoresSafeArea(edges: .bottom)
            }
            
            // MARK: - Main Content Container
            VStack(spacing: 25) {
                
                Spacer()
                
                // MARK: - App Logo
                Image("logo white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.bottom, 5)
                
                // MARK: - Title Styling
                Text("Welcome to Clamera!")
                    .font(.custom("ChalkboardSE-Bold", size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // MARK: - Subtitle
                Text("Please choose a username so your friends can find you.")
                    .font(.custom("HelveticaNeue-Thin", size: 20))
                    .bold()
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // MARK: - Username Text Field
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .frame(height: 50)
                    
                    TextField("Enter Username", text: $newUsername)
                        .foregroundStyle(.gray)
                        .tint(.gray)
                        .bold()
                        .padding(.leading, 15)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .frame(maxWidth: 350)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // MARK: - Submit Button
                Button {
                    Task {
                        await AuthManager.shared.finalizeGoogleSignUp(chosenUsername: newUsername)
                    }
                } label: {
                    Text("Complete Sign Up")
                        .foregroundStyle(.white)
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(newUsername.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .frame(maxWidth: 350)
                .padding(.horizontal, 20)
                .disabled(newUsername.isEmpty)
                
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    CreateUsernameView()
}

//
//  ProfileView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // MARK: - Header
                VStack(spacing: 10) {
        
                    
                    // Profile picture
                    Image(user.profilePicture)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                    
                    // Username
                    Text(user.username)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black.opacity(0.85))
                }
                .padding(.top, 40)
                
                // MARK: - Info Section
                VStack(spacing: 0) {
                    
                    infoRow(title: "Email", value: user.email)
                    divider()
                    
                    infoRow(title: "Password", value: "*****")
                    divider()
                    
                    infoRow(title: "Fish Caught", value: "\(user.speciesStore.getFish())")
                    divider()
                    
                    infoRow(title: "Species Caught", value: "\(user.speciesStore.getSpecies())/\(user.speciesStore.speciesList.count)")
                    divider()
                    
                    infoRow(title: "Clam Points", value: "\(user.speciesStore.totalClamPoints)")
                    
                }
                .background(RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4))
                .padding(.horizontal)
                
                // MARK: - Logout Button
                Button {
                    // Logout action
                } label: {
                    Text("Logout")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red.opacity(0.7), lineWidth: 1))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer(minLength: 30)
            }
        }
        .background(Color.blue.opacity(0.01))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Info Row Helper
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.black)
                .bold()
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
    
    // MARK: - Divider Helper
    private func divider() -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.05))
            .frame(height: 1)
            .padding(.horizontal)
    }
}

#Preview {
    ProfileView()
        .environmentObject(User())
}

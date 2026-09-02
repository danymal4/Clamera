//
//  ProfileView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var user: User
    @State private var showingEditProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                HStack {
                    Spacer()
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Text("Edit")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                .padding(.top, 10)
                    .padding(.trailing, 10)
                }
    
                VStack(spacing: 10) {
                    
                    // Profile picture
                    if user.profilePicture.hasPrefix("http") {
                        AsyncImage(url: URL(string: user.profilePicture)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                    } else if let data = Data(base64Encoded: user.profilePicture),
                              let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .foregroundColor(.gray.opacity(0.6))
                            .background(Circle().fill(Color(.systemGray5)))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                    }

                    // Username
                    Text(user.username)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black.opacity(0.85))
                }
                .padding(.top, 40)


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


                Button {
                    Task{
                        if let user = AuthManager.shared.user {
                            await FirestoreManager.shared.saveUser(user: user)
                        }
                        AuthManager.shared.signOut()
                    }
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
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: user)
        }
    }


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

//
//  EditProfileView.swift
//  Clamera
//
//  Created by Isaac on 3/5/26.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: User
    
    @State private var username: String
    @State private var email: String
    @State private var password: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    
    init(user: User) {
        _username = State(initialValue: user.username)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Photo")) {
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(user.profilePicture)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            }

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(Color.white))
                            }
                        }
                        .padding(.vertical, 10)
                        Spacer()
                    }
                }

                Section(header: Text("Account Information")) {
                    TextField("Username", text: $username)implement the required auth stuff to allow the user to change their password in 
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("New Password", text: $password)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        user.username = username
                        user.email = email
                        // Note: Password update logic would go here if Auth supports it

                        // Handle image upload/update logic here if needed

                        user.leaderboardUser.name = username
                        
                        Task {
                            await FirestoreManager.shared.saveUser(user: user)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImage = uiImage
                    }
                }
            }
        }
    }
}


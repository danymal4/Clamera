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
                            } else if user.profilePicture.hasPrefix("http") {
                                AsyncImage(url: URL(string: user.profilePicture)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
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
                    TextField("Username", text: $username)
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
                        user.leaderboardUser.name = username
                        
                        Task {
                            if let profileImage = profileImage,
                               let imageData = profileImage.jpegData(compressionQuality: 0.8) {
                                do {
                                    let urlString = try await FirestoreManager.shared.uploadProfileImage(data: imageData, userId: user.id)
                                    user.profilePicture = urlString
                                } catch {
                                    print("Error uploading image: \(error)")
                                }
                            }

                            await FirestoreManager.shared.saveUser(user: user)
                            await MainActor.run {
                        presentationMode.wrappedValue.dismiss()
                }
            }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                }
            }

            }


            .onChange(of: selectedItem) { oldItem, newItem in
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


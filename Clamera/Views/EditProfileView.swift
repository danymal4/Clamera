//
//  EditProfileView.swift
//  Clamera
//
//  Created by Assistant on 3/5/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: User
    
    @State private var username: String
    @State private var profilePicture: String
    
    init(user: User) {
        _username = State(initialValue: user.username)
        _profilePicture = State(initialValue: user.profilePicture)
    }
    
    // Simple list of available profile pictures
    let profilePictures = ["fisherman", "person.circle", "person.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Username", text: $username)
                    
                    Picker("Profile Picture", selection: $profilePicture) {
                        ForEach(profilePictures, id: \.self) { pic in
                            Text(pic).tag(pic)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        user.username = username
                        user.profilePicture = profilePicture
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
        }
    }
}


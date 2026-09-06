//
//  EditProfileView.swift
//  Clamera
//
//  Created by Isaac on 3/5/26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: User
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isApplying = false
    
    // Password change states
    @State private var showPasswordPrompt = false
    @State private var currentPasswordInput = ""
    @State private var newPasswordInput = ""
    @State private var passwordErrorMessage: String? = nil
    @State private var passwordSuccessMessage: String? = nil
    @State private var isUpdatingPassword = false
    
    init(user: User) { }
    
    // Check if the current user signed in using email/password (hides for Google accounts)
    private var isEmailUser: Bool {
        guard let currentUser = Auth.auth().currentUser else { return false }
        return currentUser.providerData.contains { $0.providerID == "password" }
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
                            } else if let data = Data(base64Encoded: user.profilePicture),
                                      let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray.opacity(0.6))
                            }

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(Color.white))
                            }
                            .disabled(isApplying)
                        }
                        .padding(.vertical, 10)
                        Spacer()
                    }
                }

                Section(header: Text("Account Information")) {
                    // Read-only Username
                    HStack {
                        Text("Username")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(user.username.isEmpty ? "Angler" : user.username)
                            .foregroundColor(.primary)
                    }

                    // Read-only Email
                    HStack {
                        Text("Email")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(user.email)
                            .foregroundColor(.primary)
                    }
                    
                    if isEmailUser {
                        Button("Change Password") {
                            currentPasswordInput = ""
                            newPasswordInput = ""
                            passwordErrorMessage = nil
                            passwordSuccessMessage = nil
                            showPasswordPrompt = true
                        }
                        .foregroundColor(.blue)
                        .disabled(isApplying)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isApplying {
                        ProgressView()
                    } else {
                        Button("Apply") {
                            isApplying = true
                            Task {
                                if let profileImage = profileImage {
                                    // Resize to a small fixed dimension BEFORE
                                    // compressing, so the resulting Base64
                                    // string stays well under Firestore's
                                    // 1 MiB document limit.
                                    let resized = resizeImage(profileImage, targetSize: CGSize(width: 300, height: 300))
                                    if let imageData = resized.jpegData(compressionQuality: 0.6) {
                                        let base64String = imageData.base64EncodedString()
                                        await MainActor.run {
                                            user.profilePicture = base64String
                                        }
                                    }
                                }

                                await FirestoreManager.shared.saveUser(user: user)
                                await MainActor.run {
                                    isApplying = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isApplying)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem = newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.profileImage = uiImage
                        }
                    }
                }
            }
            .sheet(isPresented: $showPasswordPrompt) {
                NavigationStack {
                    Form {
                        Section(header: Text("Security")) {
                            SecureField("Current Password", text: $currentPasswordInput)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            SecureField("New Password", text: $newPasswordInput)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        if let passwordErrorMessage {
                            Section {
                                Text(passwordErrorMessage)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if let passwordSuccessMessage {
                            Section {
                                Text(passwordSuccessMessage)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .navigationTitle("Change Password")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showPasswordPrompt = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Update") {
                                isUpdatingPassword = true
                                passwordErrorMessage = nil
                                Task {
                                    do {
                                        guard let currentUser = Auth.auth().currentUser, let email = currentUser.email else {
                                            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active user found."])
                                        }
                                        
                                        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPasswordInput)
                                        try await currentUser.reauthenticate(with: credential)
                                        try await currentUser.updatePassword(to: newPasswordInput)
                                        
                                        await MainActor.run {
                                            isUpdatingPassword = false
                                            passwordSuccessMessage = "Password updated successfully!"
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                                showPasswordPrompt = false
                                            }
                                        }
                                    } catch {
                                        await MainActor.run {
                                            isUpdatingPassword = false
                                            passwordErrorMessage = "Failed to update password. Check your current password."
                                        }
                                    }
                                }
                            }
                            .disabled(currentPasswordInput.isEmpty || newPasswordInput.isEmpty || isUpdatingPassword)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let scaledSize = CGSize(
            width: image.size.width * scaleFactor,
            height: image.size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
}

#Preview {
    EditProfileView(user: User())
        .environmentObject(User())
}

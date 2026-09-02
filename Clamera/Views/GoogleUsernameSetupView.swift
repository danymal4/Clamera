//
//  GoogleUsernameSetupView.swift
//  Clamera
//
//  Created by Dany Malaeb on 9/1/26.
//

import SwiftUI

struct GoogleUsernameSetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var usernameInput = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                 
                Image("logo white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
                 
                Text("Welcome to Clamera!")
                    .font(.system(size: 32, weight: .bold))
                 
                Text("Please choose a unique username so your friends can find and add you.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                 
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                    
                    TextField("Enter username", text: $usernameInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
                .frame(maxWidth: 350)
                .padding(.horizontal, 20)
                 
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                 
                Button {
                    let cleaned = usernameInput.trimmingCharacters(in: .whitespaces)
                    guard !cleaned.isEmpty else { return }
                     
                    isLoading = true
                    errorMessage = nil
                     
                    Task {
                        let existing = await FirestoreManager.shared.findUserByUsername(cleaned)
                        await MainActor.run {
                            isLoading = false
                            if existing != nil {
                                errorMessage = "This username is already taken. Choose another."
                            } else {
                                Task {
                                    await authManager.finalizeGoogleSignUp(chosenUsername: cleaned)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .cyan.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .disabled(usernameInput.isEmpty || isLoading)
                .frame(maxWidth: 350)
                .padding(.horizontal, 20)
                 
                Spacer()
            }
            .navigationTitle("Setup Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                authManager.signOut()
            })
        }
        .interactiveDismissDisabled()
    }
}
#Preview {
    GoogleUsernameSetupView()
        .environmentObject(AuthManager.shared)
}

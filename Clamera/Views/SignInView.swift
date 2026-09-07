//
//  SignInView.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/31/26.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @State private var emailOrUsername = ""
    @State private var password = ""
    @State private var step: SignInStep = .email
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSignUp = false
    @State private var showPassword = false // Controls visibility toggle
    
    @State private var failedAttempts = 0
    
    // Separate loading flag just for the Google button, so it can show its
    // own spinner without being tied to the email/password flow's isLoading.
    @State private var isGoogleSignInLoading = false
    // Holds the raw (unhashed) nonce between the Apple button's onRequest
    // and onCompletion callbacks so it can be verified against the token
    // Apple returns.
    @State private var appleSignInNonce: String?
    @FocusState private var isFieldFocused: Bool
    
    enum SignInStep {
        case email
        case password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                 
                VStack {
                    Spacer()
                    WaterView()
                        .frame(height: 360)
                        .opacity(0.4)
                        .ignoresSafeArea(edges: .bottom)
                }
                 
                // MARK: - Rigid Content Container (Matched geometry, zero bouncing)
                VStack(spacing: 24) {
                    Color.clear
                        .frame(height: 10)
                     
                    // MARK: - Logo & Title Header
                    VStack(spacing: 12) {
                        Image("logo white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
                         
                        Text("Clamera")
                            .font(.custom("ChalkboardSE-Bold", size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                         
                        Text(step == .email ? "Sign In To Your Account" : "Welcome Back!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                     
                    // MARK: - Progressive Form Fields
                    VStack(spacing: 16) {
                        if step == .email {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email or Username")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                 
                                TextField("Enter your email or username", text: $emailOrUsername)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($isFieldFocused)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                             
                            Button {
                                let cleanedInput = emailOrUsername.trimmingCharacters(in: .whitespaces)
                                guard !cleanedInput.isEmpty else { return }
                                
                                isLoading = true
                                errorMessage = nil
                                
                                Task {
                                    let exists: Bool
                                    if cleanedInput.contains("@") {
                                        exists = true
                                    } else {
                                        let profile = await FirestoreManager.shared.findUserByUsername(cleanedInput)
                                        exists = (profile != nil)
                                    }
                                    
                                    await MainActor.run {
                                        isLoading = false
                                        if exists {
                                            failedAttempts = 0
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                step = .password
                                            }
                                        } else {
                                            errorMessage = "This username or email does not exist."
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Next")
                                            .font(.headline)
                                        Image(systemName: "arrow.right")
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
                            .disabled(isLoading)
                            .padding(.top, 8)
                             
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            step = .email
                                            failedAttempts = 0
                                            errorMessage = nil
                                        }
                                    } label: {
                                        Label("Back", systemImage: "chevron.left")
                                            .font(.caption.bold())
                                            .foregroundColor(.cyan)
                                    }
                                    Spacer()
                                    Text(emailOrUsername)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 4)
                                 
                                Text("Password")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                 
                                // Password field with visibility toggle
                                HStack {
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .focused($isFieldFocused)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .focused($isFieldFocused)
                                    }
                                     
                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                             
                            Button {
                                handleSignIn()
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign In")
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
                            .disabled(isLoading || password.isEmpty)
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: 350)
                    .padding(.horizontal, 20)
                    .transaction { $0.animation = nil }
                     
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if failedAttempts >= 3 {
                        Text("If you originally signed up using Google, tap \"Sign in with Google\" below instead of entering a password.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                     
                    Spacer()
                     
                    // MARK: - Secondary Options (Fixed at bottom)
                    VStack(spacing: 14) {
                        Divider()
                            .padding(.horizontal, 40)
                         
                        HStack {
                            Text("Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                             
                            Button("Sign Up") {
                                showSignUp = true
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.cyan)
                        }
                         
                        Button {
                            isGoogleSignInLoading = true
                            Task {
                                await AuthManager.shared.signInWithGoogle()
                                await MainActor.run {
                                    isGoogleSignInLoading = false
                                }
                            }
                        } label: {
                            ZStack {
                                Image("GoogleIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .opacity(isGoogleSignInLoading ? 0 : 1)
                                
                                if isGoogleSignInLoading {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isGoogleSignInLoading)
                        .frame(maxWidth: 350)
                        .padding(.horizontal, 20)

                        SignInWithAppleButton(.signIn) { request in
                            let nonce = AuthManager.randomNonceString()
                            appleSignInNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = AuthManager.sha256(nonce)
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                      let nonce = appleSignInNonce,
                                      let identityToken = credential.identityToken,
                                      let idTokenString = String(data: identityToken, encoding: .utf8) else {
                                    print("Apple sign-in: missing credential/nonce/token")
                                    return
                                }
                                Task {
                                    await authManager.signInWithApple(idTokenString: idTokenString, nonce: nonce, fullName: credential.fullName)
                                }
                            case .failure(let error):
                                print("Apple sign-in failed: \(error.localizedDescription)")
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(maxWidth: 350, minHeight: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFieldFocused = false
                    }
                }
            }
        }
    }
     
    private func handleSignIn() {
        isLoading = true
        errorMessage = nil
         
        Task {
            do {
                try await AuthManager.shared.signIn(loginInput: emailOrUsername, password: password)
                await MainActor.run {
                    isLoading = false
                    failedAttempts = 0
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    failedAttempts += 1
                    errorMessage = "Incorrect password or email. Please try again."
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthManager.shared)
}

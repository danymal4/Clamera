//
//  SignUpView.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/31/26.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var step: SignUpStep = .username
    @State private var showSignIn = false
    @ObservedObject var authManager = AuthManager.shared
    
    @State private var isLoading = false
    @State private var errorMessage: String?

    enum SignUpStep {
        case username
        case password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                // MARK: - WaterView Background (Pinned securely to the bottom)
                VStack {
                    Spacer()
                    WaterView()
                        .frame(height: 360)
                        .opacity(0.4)
                        .ignoresSafeArea(edges: .bottom)
                }
                
                // MARK: - Rigid Content Container (Matches SignInView layout exactly)
                VStack(spacing: 24) {
                    // Fixed top padding guarantees identical text box heights across both views
                    Color.clear
                        .frame(height: 10)
                    
                    // MARK: - App Logo & Header
                    VStack(spacing: 12) {
                        Image("logo white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 4)
                        
                        Text("Clamera")
                            .font(.custom("ChalkboardSE-Bold", size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(step == .username ? "Create an account" : "Set your password")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - Progressive Form Fields with Slide Transition
                    VStack(spacing: 16) {
                        if step == .username {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Username")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                
                                TextField("Create a username", text: $username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            
                            Button {
                                guard !username.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    step = .password
                                }
                            } label: {
                                HStack {
                                    Text("Next")
                                        .font(.headline)
                                    Image(systemName: "arrow.right")
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
                            .padding(.top, 8)
                            
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            step = .username
                                        }
                                    } label: {
                                        Label("Back", systemImage: "chevron.left")
                                            .font(.caption.bold())
                                            .foregroundColor(.cyan)
                                    }
                                    Spacer()
                                    Text(username)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 4)
                                
                                Text("Password")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                
                                SecureField("Create a password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                            
                            Button {
                                Task {
                                    isLoading = true
                                    await AuthManager.shared.signUp(username: username, email: email, password: password)
                                    isLoading = false
                                }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign Up")
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
                    }
                    
                    Spacer()
                    
                    // MARK: - Secondary Options (Fixed at bottom)
                    VStack(spacing: 14) {
                        Divider()
                            .padding(.horizontal, 40)
                        
                        Button {
                            showSignIn = true
                        } label: {
                            Text("Already have an account? Sign In")
                                .font(.subheadline.bold())
                                .foregroundColor(.cyan)
                        }
                        
                        Button {
                            Task {
                                await AuthManager.shared.signInWithGoogle()
                            }
                        } label: {
                            Image("GoogleIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                        }
                        .frame(maxWidth: 350)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $authManager.needsUsernameSetup) {
                CreateUsernameView()
            }
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
        }
    }
}

#Preview {
    SignUpView()
}

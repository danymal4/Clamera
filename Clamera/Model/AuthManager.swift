//
//  AuthManager.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 3/25/26.
//

import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var user: User?
    @Published var needsUsernameSetup: Bool = false
    @Published var pendingGoogleUser: FirebaseAuth.User? = nil
    @Published var isLoading: Bool = true
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                let email = firebaseUser.email ?? ""
                let uid = firebaseUser.uid
                self?.user = User(id: uid, email: email)
                 
                Task {
                    if let user = self?.user {
                        await FirestoreManager.shared.fetchUser(user: user)
                    }
                }
            } else {
                self?.user = nil
            }
            self?.isLoading = false
        }
    }
     
    @MainActor
    func signUp(username: String, email: String, password: String) async {
        guard let result = try? await Auth.auth().createUser(withEmail: email, password: password) else {
            return
        }
         
        user = User(id: result.user.uid, username: username, email: result.user.email ?? "")
    }
     
    @MainActor
    func signIn(loginInput: String, password: String) async throws {
        var emailToUse = loginInput
         
        if !loginInput.contains("@") {
            let db = Firestore.firestore()
             
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: loginInput)
                .getDocuments()
             
            guard let document = snapshot.documents.first else {
                throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No account found with that username."])
            }
             
            guard let fetchedEmail = document.data()["email"] as? String else {
                throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Could not find an email attached to this username."])
            }
             
            emailToUse = fetchedEmail
        }
         
        let result = try await Auth.auth().signIn(withEmail: emailToUse, password: password)
         
        user = User(id: result.user.uid, email: result.user.email ?? emailToUse)
        await FirestoreManager.shared.fetchUser(user: user ?? User())
        print("Signed in successfully!")
    }
     
    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("AuthManager: Could not retrieve client ID from Firebase configuration.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
         
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("AuthManager: Could not find root view controller")
            return
        }
         
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let googleUser = result.user
        guard let idToken = googleUser.idToken?.tokenString else {
            print("AuthManager Line 80: idToken not found")
            return
        }
         
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: googleUser.accessToken.tokenString)
        
        let authResult = try await Auth.auth().signIn(with: credential)
         
        let db = Firestore.firestore()
        let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
         
        if userDoc.exists {
            self.user = User(id: authResult.user.uid, email: authResult.user.email ?? "")
            await FirestoreManager.shared.fetchUser(user: self.user ?? User())
             
            print("Successfully signed in! User: \(authResult.user.uid)")
        } else {
            print("New Google user detected! Stopping login to prompt for username.")
            self.pendingGoogleUser = authResult.user
            self.needsUsernameSetup = true
        }
    }
     
    @MainActor
    func finalizeGoogleSignUp(chosenUsername: String) async {
        guard let googleUser = pendingGoogleUser else { return }
         
        let db = Firestore.firestore()
        let lowercasedUsername = chosenUsername.lowercased()
         
        let userData: [String: Any] = [
            "username": chosenUsername,
            "username_lowercase": lowercasedUsername,
            "email": googleUser.email ?? "",
            "friends": []
        ]
         
        do {
            try await db.collection("users").document(googleUser.uid).setData(userData)
             
            self.user = User(id: googleUser.uid, username: chosenUsername, email: googleUser.email ?? "")
            await FirestoreManager.shared.fetchUser(user: self.user ?? User())
             
            self.needsUsernameSetup = false
            self.pendingGoogleUser = nil
             
            print("Account fully created with username: \(chosenUsername)")
        } catch {
            print("Error saving new user data: \(error.localizedDescription)")
        }
    }
     
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            print("signed out")
        } catch {
            print(error)
        }
    }
}

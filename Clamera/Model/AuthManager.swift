//
//  AuthManager.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 3/25/26.
//

import Foundation
import Combine   // Provides @Published — the reactive framework that powers SwiftUI observation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

// ObservableObject lets SwiftUI subscribe to this class via @StateObject / @EnvironmentObject.
// When any @Published property changes, SwiftUI re-renders views that depend on it.
class AuthManager: ObservableObject{
    // Singleton — one shared instance lives in memory for the entire app lifecycle.
    // Views access it via AuthManager.shared or through the @EnvironmentObject injection.
    static let shared = AuthManager()
    
    // @Published makes this property observable via Combine.
    // When user is set, it fires objectWillChange, which tells SwiftUI to re-render.
    @Published var user: User?
    
    @MainActor
    func signUp(username: String, email: String, password: String) async {
        
        // Auth.auth() returns the Firebase Auth singleton (similar to how we use our own singleton).
        // createUser is async — it sends a request to Firebase servers to register a new account.
        // Returns an AuthDataResult containing the new user's uid and email.
        guard let result = try? await Auth.auth().createUser(withEmail: email, password: password) else {
            return
        }
        
        // Setting user triggers @Published, which tells SwiftUI to re-render.
        // This is what causes ContentView to switch from LoginView to ProfileView.
        
        user = User(id: result.user.uid, username: username, email: result.user.email ?? "")
    }
    
    @MainActor
    func signIn(email: String, password: String) async {
        do {
            // signIn checks credentials against Firebase Auth servers.
            // Returns an AuthDataResult on success, throws on failure (wrong password, etc.)
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Same as signUp — setting user triggers the UI to switch to ProfileView
            user = User(id: result.user.uid, email: result.user.email ?? "")
            await FirestoreManager.shared.fetchUser(user: user ?? User())
            print("signed in")
            
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func signInWithGoogle() async throws {
        // 1. Get the Client ID from Firebase configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("AuthManager Line 61: Could not retrieve client ID from Firebase configuration.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 2. Find the "Presenting View Controller" (the window currently on screen)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Could not find root view controller")
            return
        }
        
        // 3. Start the Google Sign-In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        // 4. Get the tokens from the Google User
        let user = result.user
        guard let idToken = user.idToken?.tokenString else { return }
        
        // 5. Create the Firebase Credential
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)
        
        // 6. Sign in to Firebase with that credential
        let authResult = try await Auth.auth().signIn(with: credential)
        print("Successfully signed in! User: \(authResult.user.uid)")
    }
    
    func signOut(){
        do {
            // Clears the local Firebase Auth session
            try Auth.auth().signOut()
            // Setting user to nil triggers @Published — UI switches back to LoginView
            user = nil
            print("signed out")
        } catch {
            print(error)
        }
    }
}


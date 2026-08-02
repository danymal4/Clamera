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
import FirebaseFirestore

// ObservableObject lets SwiftUI subscribe to this class via @StateObject / @EnvironmentObject.
// When any @Published property changes, SwiftUI re-renders views that depend on it.
class AuthManager: ObservableObject {
    // Singleton — one shared instance lives in memory for the entire app lifecycle.
    // Views access it via AuthManager.shared or through the @EnvironmentObject injection.
    static let shared = AuthManager()
    
    // @Published makes this property observable via Combine.
    // When user is set, it fires objectWillChange, which tells SwiftUI to re-render.
    @Published var user: User?
    
    // variables for when user signs up with google
    @Published var needsUsernameSetup: Bool = false
    @Published var pendingGoogleUser: FirebaseAuth.User? = nil
    
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
    func signIn(loginInput: String, password: String) async {
        do {
            // The email we will eventually pass to Firebase Auth
            var emailToUse = loginInput
            
            // 1. Check if the input is a username (no '@' symbol)
            if !loginInput.contains("@") {
                let db = Firestore.firestore()
                
                // Search Firestore for the username
                let snapshot = try await db.collection("users")
                    .whereField("username", isEqualTo: loginInput)
                    .getDocuments()
                
                guard let document = snapshot.documents.first else {
                    print("Login Failed: No account found with that username.")
                    return
                }
                
                guard let fetchedEmail = document.data()["email"] as? String else {
                    print("Login Failed: Could not find an email attached to this username.")
                    return
                }
                
                // Swap the input out for the secret email we just found
                emailToUse = fetchedEmail
            }
            
            // 2. Sign into Firebase Auth (using either the typed email, or the fetched email)
            let result = try await Auth.auth().signIn(withEmail: emailToUse, password: password)
            
            // 3. Complete the login
            user = User(id: result.user.uid, email: result.user.email ?? emailToUse)
            await FirestoreManager.shared.fetchUser(user: user ?? User())
            print("Signed in successfully!")
            
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    @MainActor
    func signInWithGoogle() async throws {
        // Get the Client ID from Firebase configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("AuthManager: Could not retrieve client ID from Firebase configuration.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Find the "Presenting View Controller" (the window currently on screen)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("AuthManager: Could not find root view controller")
            return
        }
        
        // Start the Google Sign-In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        // Get the tokens from the Google User
        let googleUser = result.user
        guard let idToken = googleUser.idToken?.tokenString else {
            print("AuthManager Line 80: idToken not found")
            return
        }
        
        // Create the Firebase Credential
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: googleUser.accessToken.tokenString)
        
        // Sign in to Firebase with that credential
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // --- NEW LOGIC: Check Firestore for an existing profile ---
        let db = Firestore.firestore()
        let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
        
        if userDoc.exists {
            // PATH A: Returning User (They already have a username in Firestore)
            self.user = User(id: authResult.user.uid, email: authResult.user.email ?? "")
            await FirestoreManager.shared.fetchUser(user: self.user ?? User())
            
            print("Successfully signed in! User: \(authResult.user.uid)")
        } else {
            // PATH B: Brand New User (No Firestore document yet)
            print("New Google user detected! Stopping login to prompt for username.")
            
            // Save the Firebase user temporarily so we can create their document later
            self.pendingGoogleUser = authResult.user
            
            // Trigger the UI to show the "Create Username" screen
            self.needsUsernameSetup = true
        }
    }
    

    
    
    
    @MainActor
    func finalizeGoogleSignUp(chosenUsername: String) async {
        // Make sure we have a paused Google user waiting
        guard let googleUser = pendingGoogleUser else { return }
        
        let db = Firestore.firestore()
        let lowercasedUsername = chosenUsername.lowercased()
        
        // The data to save in Firestore
        let userData: [String: Any] = [
            "username": chosenUsername,
            "username_lowercase": lowercasedUsername,
            "email": googleUser.email ?? "",
            "friends": [] // Initialize with an empty friends list
        ]
        
        do {
            // 1. Create their official document in the 'users' collection
            try await db.collection("users").document(googleUser.uid).setData(userData)
            
            // 2. Set the current user so the app transitions to the main view
            self.user = User(id: googleUser.uid, username: chosenUsername, email: googleUser.email ?? "")
            await FirestoreManager.shared.fetchUser(user: self.user ?? User())
            
            // 3. Reset the setup variables so the popup goes away
            self.needsUsernameSetup = false
            self.pendingGoogleUser = nil
            
            print("Account fully created with username: \(chosenUsername)")
        } catch {
            print("Error saving new user data: \(error.localizedDescription)")
        }
    }
    
    
    
    
    func signOut() {
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

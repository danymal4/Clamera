//
//  AuthManager.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 3/25/26.
//

import Foundation
import Combine   // Provides @Published — the reactive framework that powers SwiftUI observation
import FirebaseAuth

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


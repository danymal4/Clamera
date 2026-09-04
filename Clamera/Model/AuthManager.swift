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

struct PendingGoogleUser: Identifiable {
    let id: String
    let firebaseUser: FirebaseAuth.User
    
    init(_ firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.firebaseUser = firebaseUser
    }
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var user: User?
    @Published var needsUsernameSetup: Bool = false
    @Published var pendingGoogleUser: PendingGoogleUser? = nil
    @Published var isLoading: Bool = true
    
    /// True while signUp() or signIn() is actively in progress. The
    /// auth-state listener below checks this and skips its own routing
    /// logic when true, since those functions already handle routing
    /// themselves — this prevents a race where the listener briefly
    /// flashes the Google username sheet for a non-Google signup, just
    /// because the account technically "signed in" a moment before the
    /// Firestore document was finished being written.
    private var isHandlingAuthManually = false
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            guard !self.isHandlingAuthManually else { return }
            
            if let firebaseUser = firebaseUser {
                let uid = firebaseUser.uid
                let email = firebaseUser.email ?? ""
                 
                Task {
                    let db = Firestore.firestore()
                    do {
                        let userDoc = try await db.collection("users").document(uid).getDocument()
                        
                        if userDoc.exists, let data = userDoc.data(), let username = data["username"] as? String, !username.isEmpty {
                            print("AuthManager: [listener] User document found with valid username: \(username)")
                            let fetchedUser = User(id: uid, email: email)
                            await FirestoreManager.shared.fetchUser(user: fetchedUser)
                            
                            await MainActor.run {
                                self.user = fetchedUser
                                self.needsUsernameSetup = false
                                self.pendingGoogleUser = nil
                                self.isLoading = false
                            }
                        } else {
                            print("AuthManager: [listener] User document missing or username empty.")
                            await MainActor.run {
                                self.pendingGoogleUser = PendingGoogleUser(firebaseUser)
                                self.needsUsernameSetup = true
                                self.user = nil
                                self.isLoading = false
                            }
                        }
                    } catch {
                        print("AuthManager: Error fetching user doc (\(error.localizedDescription)). Forcing setup view as fallback.")
                        await MainActor.run {
                            self.pendingGoogleUser = PendingGoogleUser(firebaseUser)
                            self.needsUsernameSetup = true
                            self.user = nil
                            self.isLoading = false
                        }
                    }
                }
            } else {
                Task { @MainActor in
                    self.user = nil
                    self.needsUsernameSetup = false
                    self.pendingGoogleUser = nil
                    self.isLoading = false
                }
            }
        }
    }
     
    @MainActor
    func signUp(username: String, email: String, password: String) async throws {
        isHandlingAuthManually = true
        defer { isHandlingAuthManually = false }
        
        let cleanedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let isAvailable = await FirestoreManager.shared.isUsernameAvailable(cleanedUsername, currentUserId: "")
        guard isAvailable else {
            throw NSError(domain: "AuthError", code: 409, userInfo: [NSLocalizedDescriptionKey: "That username is already taken."])
        }
        
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        let lowercasedUsername = cleanedUsername.lowercased()
        
        let reserved = await FirestoreManager.shared.reserveUsername(cleanedUsername, uid: uid, email: email)
        guard reserved else {
            throw NSError(domain: "AuthError", code: 409, userInfo: [NSLocalizedDescriptionKey: "That username was just taken. Please choose another."])
        }
        
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "username": cleanedUsername,
            "username_lowercase": lowercasedUsername,
            "email": email,
            "profile picture": "fisherman",
            "clampoints": 0,
            "aquarium fish": [],
            "fish of fame posts": [],
            "friends": [],
            "incoming_requests": [],
            "outgoing_requests": [],
            "unlocked shop items": []
        ]
        
        try await db.collection("users").document(uid).setData(userData)
        
        let newUser = User(id: uid, username: cleanedUsername, email: email)
        await FirestoreManager.shared.fetchUser(user: newUser)
        self.user = newUser
        self.needsUsernameSetup = false
        self.pendingGoogleUser = nil
        
        print("Account fully created for username: \(cleanedUsername)")
    }
     
    @MainActor
    func signIn(loginInput: String, password: String) async throws {
        isHandlingAuthManually = true
        defer { isHandlingAuthManually = false }
        
        var emailToUse = loginInput
         
        if !loginInput.contains("@") {
            let db = Firestore.firestore()
            let cleanedInput = loginInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
             
            let mappingDoc = try await db.collection("usernames").document(cleanedInput).getDocument()
             
            guard mappingDoc.exists, let data = mappingDoc.data() else {
                throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No account found with that username."])
            }
             
            guard let fetchedEmail = data["email"] as? String else {
                throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Could not find an email attached to this username."])
            }
             
            emailToUse = fetchedEmail
        }
         
        let result = try await Auth.auth().signIn(withEmail: emailToUse, password: password)
         
        let tempUser = User(id: result.user.uid, email: result.user.email ?? emailToUse)
        await FirestoreManager.shared.fetchUser(user: tempUser)
        user = tempUser
        print("Signed in successfully!")
    }
     
    @MainActor
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("AuthManager: Could not retrieve client ID.")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
         
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("AuthManager: Could not find root view controller")
            return
        }
         
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let googleUser = result.user
            guard let idToken = googleUser.idToken?.tokenString else {
                print("AuthManager: idToken not found")
                return
            }
             
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: googleUser.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            print("Successfully signed in with Google! UID: \(authResult.user.uid)")
             
            await checkUserDocumentAndRoute(firebaseUser: authResult.user)
        } catch {
            print("GOOGLE SIGN-IN ERROR: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func checkUserDocumentAndRoute(firebaseUser: FirebaseAuth.User) async {
        let db = Firestore.firestore()
        let uid = firebaseUser.uid
        let email = firebaseUser.email ?? ""
         
        do {
            let userDoc = try await db.collection("users").document(uid).getDocument()
             
            if userDoc.exists, let data = userDoc.data(), let username = data["username"] as? String, !username.isEmpty {
                print("AuthManager: [google] User document found with valid username: \(username)")
                let fetchedUser = User(id: uid, email: email)
                await FirestoreManager.shared.fetchUser(user: fetchedUser)
                 
                self.user = fetchedUser
                self.needsUsernameSetup = false
                self.pendingGoogleUser = nil
                self.isLoading = false
            } else {
                print("AuthManager: [google] User document missing or username empty. Forcing setup view.")
                self.pendingGoogleUser = PendingGoogleUser(firebaseUser)
                self.needsUsernameSetup = true
                self.user = nil
                self.isLoading = false
            }
        } catch {
            print("AuthManager: [google] Error fetching user doc (\(error.localizedDescription)). Forcing setup view as fallback.")
            self.pendingGoogleUser = PendingGoogleUser(firebaseUser)
            self.needsUsernameSetup = true
            self.user = nil
            self.isLoading = false
        }
    }
     
    @MainActor
    func finalizeGoogleSignUp(chosenUsername: String) async {
        guard let pending = pendingGoogleUser else { return }
        let googleUser = pending.firebaseUser
        let email = googleUser.email ?? ""
         
        let reserved = await FirestoreManager.shared.reserveUsername(chosenUsername, uid: googleUser.uid, email: email)
        guard reserved else {
            print("AuthManager: Username '\(chosenUsername)' is already taken or reservation failed.")
            return
        }
         
        let db = Firestore.firestore()
        let lowercasedUsername = chosenUsername.lowercased()
         
        let userData: [String: Any] = [
            "username": chosenUsername,
            "username_lowercase": lowercasedUsername,
            "email": email,
            "profile picture": "fisherman",
            "species list": [:],
            "clampoints": 0,
            "aquarium fish": [],
            "fish of fame posts": [],
            "friends": [],
            "incoming_requests": [],
            "outgoing_requests": [],
            "unlocked shop items": []
        ]
         
        do {
            try await db.collection("users").document(googleUser.uid).setData(userData)
             
            let newUser = User(id: googleUser.uid, email: email)
            await FirestoreManager.shared.fetchUser(user: newUser)
            
            self.needsUsernameSetup = false
            self.pendingGoogleUser = nil
            self.user = newUser
             
            print("Account fully created with complete profile structure for: \(chosenUsername)")
        } catch {
            print("Error saving new user data: \(error.localizedDescription)")
        }
    }
     
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            needsUsernameSetup = false
            pendingGoogleUser = nil
            isLoading = false
            print("signed out")
        } catch {
            print(error)
        }
    }
}

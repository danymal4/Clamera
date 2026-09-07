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
import FirebaseFunctions
import AuthenticationServices
import CryptoKit

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
        newUser.passwordLength = password.count
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
            let cleanedInput = loginInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
             
            // Username -> email is resolved server-side (Cloud Function using
            // the Admin SDK) so the client never reads a document containing
            // another user's email address.
            do {
                let result = try await Functions.functions().httpsCallable("resolveUsernameToEmail").call(["username": cleanedInput])
                guard let data = result.data as? [String: Any], let fetchedEmail = data["email"] as? String else {
                    throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No account found with that username."])
                }
                emailToUse = fetchedEmail
            } catch let error as NSError where error.domain == "AuthError" {
                throw error
            } catch {
                throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No account found with that username."])
            }
        }
         
        let result = try await Auth.auth().signIn(withEmail: emailToUse, password: password)
         
        let tempUser = User(id: result.user.uid, email: result.user.email ?? emailToUse)
        // Signing in successfully proves the typed password IS the real
        // stored password, so it's safe to record its length here.
        tempUser.passwordLength = password.count
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
    
    // MARK: - Sign in with Apple

    /// Generates a cryptographically-random nonce for the Sign in with Apple
    /// request. The raw string is sent to Apple's SDK (hashed) and also kept
    /// around unhashed so Firebase can verify the returned identity token
    /// really answers this request (Apple/Firebase's standard replay-
    /// protection handshake).
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            // Extremely unlikely (would mean the system RNG is broken); fall
            // back to a still-random, if less rigorously sourced, string
            // rather than crashing the sign-in flow.
            return UUID().uuidString + UUID().uuidString
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Completes a Sign in with Apple flow that was started with a
    /// SignInWithAppleButton in the UI. `nonce` must be the same raw
    /// (unhashed) string that was hashed into the original request's
    /// nonce field.
    @MainActor
    func signInWithApple(idTokenString: String, nonce: String, fullName: PersonNameComponents?) async {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: fullName
        )

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            print("Successfully signed in with Apple! UID: \(authResult.user.uid)")
            await checkUserDocumentAndRoute(firebaseUser: authResult.user)
        } catch {
            print("APPLE SIGN-IN ERROR: \(error.localizedDescription)")
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

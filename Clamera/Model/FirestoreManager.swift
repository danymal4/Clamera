//
//  FirestoreManager.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 3/25/26.
//

import Foundation
import Combine
import FirebaseFirestore

// Same singleton + ObservableObject pattern as AuthManager.
// Firestore is Firebase's NoSQL cloud database — it stores data as
// collections of documents (like tables of JSON objects).
class FirestoreManager: ObservableObject{
    static let shared = FirestoreManager()

    // Firestore.firestore() returns the Firestore singleton, similar to Auth.auth().
    // This is our reference to the database — all reads/writes go through it.
    private let db = Firestore.firestore()

    func saveUser(user: User) async {
        do {
            // collection("users") — references the "users" collection. Created automatically if it doesn't exist.
            // document(user.id) — references a specific document using the Auth UID as the key,
            //   so each authenticated user maps to exactly one Firestore document.
            // setData — writes (or overwrites) the document with this dictionary.
            //   Keys become field names in Firestore. To update individual fields
            //   without overwriting the whole document, use updateData() instead.
            try await db.collection("users").document(user.id).setData([
                "username": user.username,
                "email": user.email,
                "profile picture": user.profilePicture,
                "species list": user.speciesStore.getDictionary(),
                "clampoints": user.speciesStore.totalClamPoints,
            ])
            print("user saved")
        } catch {
            print(error)
        }
    }

    func fetchUser(user: User) async {
        do {
            // getDocument() fetches a single document snapshot from Firestore.
            // This is a one-time read (not a live listener).
            let document = try await db.collection("users").document(user.id).getDocument()

            // document.data() returns an optional [String: Any] dictionary.
            // Firestore data is untyped, so we cast each field with `as? String`.
            if let data = document.data() {
                // MainActor.run ensures we update @Published properties on the main thread.
                // UI updates must happen on the main thread — without this, SwiftUI could crash.
                await MainActor.run {
                    user.username = data["username"] as? String ?? ""
                    user.email = data["email"] as? String ?? ""
                    user.profilePicture = data["profile picture"] as? String ?? ""
                    user.speciesStore.update(speciesList: data["species list"] as? [String:[[String:String]]] ?? [:],
                                             clamPoints: data["clampoints"] as? Int ?? 0)
                }
            }
            print("user fetched")
        } catch {
            print(error)
        }
    }
}


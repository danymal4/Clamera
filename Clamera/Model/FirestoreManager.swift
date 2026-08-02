//
//  FirestoreManager.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 3/25/26.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage
import UIKit

// Same singleton + ObservableObject pattern as AuthManager.
// Firestore is Firebase's NoSQL cloud database — it stores data as
// collections of documents (like tables of JSON objects).
class FirestoreManager: ObservableObject{
    static let shared = FirestoreManager()

    // Firestore.firestore() returns the Firestore singleton, similar to Auth.auth().
    // This is our reference to the database — all reads/writes go through it.
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func uploadProfileImage(data: Data, userId: String) async throws -> String {
        let storageRef = storage.reference().child("profile_pictures/\(userId).jpg")
        let _ = try await storageRef.putDataAsync(data, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }

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
                "aquarium fish": user.aquarium.save(),
                "week species": (user.speciesStore.catchOfTheWeek ?? Species(name: "clownfish", imageName: "clownfish")).getFullArray(),
                "week points": user.speciesStore.catchOfTheWeekPoints,
                "friends": user.friends
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
                    user.friends = data["friends"] as? [String] ?? []
                    user.speciesStore.update(speciesList: data["species list"] as? [String:[[String:String]]] ?? [:],
                                             clamPoints: data["clampoints"] as? Int ?? 0,
                                             weekSpecies: data["week species"] as? [[String:String]],
                                             weekPoints: data["week points"] as? Int ?? 100
                                            )
                    user.aquarium.loadUpdate(fishArr: data["aquarium fish"] as? [[String:String]] ?? [])
                }
            }
            print("user fetched")
        } catch {
            print(error)
        }
    }
}
extension FirestoreManager {
    
    // Fetch user details for the friends in your list
    func fetchUsers(byIds ids: [String]) async -> [Friend] {
        guard !ids.isEmpty else { return [] }
        var fetchedFriends: [Friend] = []
        
        do {
            // Firestore limit is 30 elements for 'in' queries, which works great for a standard friends list
            let querySnapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments()
                
            for doc in querySnapshot.documents {
                let data = doc.data()
                let friend = Friend(
                    id: doc.documentID,
                    name: data["username"] as? String ?? "Angler",
                    username: "@" + (data["username"] as? String ?? "angler").lowercased(),
                    imageName: data["profile picture"] as? String ?? "fisherman",
                    isOnline: true // You can dynamically calculate this if you have lastActive timestamps!
                )
                fetchedFriends.append(friend)
            }
        } catch {
            print("Error fetching friends: \(error)")
        }
        return fetchedFriends
    }
    
    // Look up a user by their exact username to add them
    func findUserByUsername(_ username: String) async -> (id: String, name: String, profilePic: String)? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .limit(to: 1)
                .getDocuments()
                
            if let doc = snapshot.documents.first {
                let data = doc.data()
                let profilePic = data["profile picture"] as? String ?? "fisherman"
                return (id: doc.documentID, name: username, profilePic: profilePic)
            }
        } catch {
            print("Error finding user: \(error)")
        }
        return nil
    }
}


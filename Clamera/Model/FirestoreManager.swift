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

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func uploadProfileImage(data: Data, userId: String) async throws -> String {
        let storageRef = storage.reference().child("profile_pictures/\(userId).jpg")
        let _ = try await storageRef.putDataAsync(data, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }

    func uploadFishPostImage(data: Data) async throws -> String {
        let storageRef = storage.reference().child("fish_posts/\(UUID().uuidString).jpg")
        let _ = try await storageRef.putDataAsync(data, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }

    func saveUser(user: User) async {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            let fishOfFameDicts = user.fishOfFamePosts.map { post -> [String: String] in
                return [
                    "id": post.id.uuidString,
                    "photo": post.photo,
                    "caption": post.caption,
                    "speciesName": post.speciesName,
                    "datePosted": dateFormatter.string(from: post.datePosted)
                ]
            }

            try await db.collection("users").document(user.id).setData([
                "username": user.username,
                "username_lowercase": user.username.lowercased(),
                "email": user.email,
                "profile picture": user.profilePicture,
                "species list": user.speciesStore.getDictionary(),
                "clampoints": user.speciesStore.totalClamPoints,
                "aquarium fish": user.aquarium.save(),
                "fish of fame posts": fishOfFameDicts,
                "friends": user.friends,
                "incoming_requests": user.incomingRequests,
                "outgoing_requests": user.outgoingRequests,
                "unlocked shop items": Array(user.unlockedShopItems)
            ], merge: true)
            print("user saved")
        } catch {
            print(error)
        }
    }

    func fetchUser(user: User) async {
        do {
            let document = try await db.collection("users").document(user.id).getDocument()

            if let data = document.data() {
                await MainActor.run {
                    user.username = data["username"] as? String ?? ""
                    user.email = data["email"] as? String ?? ""
                    user.profilePicture = data["profile picture"] as? String ?? ""
                    user.friends = data["friends"] as? [String] ?? []
                    user.incomingRequests = data["incoming_requests"] as? [String] ?? []
                    user.outgoingRequests = data["outgoing_requests"] as? [String] ?? []
                    user.unlockedShopItems = Set(data["unlocked shop items"] as? [String] ?? [])
                     
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    if let rawPosts = data["fish of fame posts"] as? [[String: String]] {
                        user.fishOfFamePosts = rawPosts.map { dict in
                            let idString = dict["id"] ?? ""
                            let uuid = UUID(uuidString: idString) ?? UUID()
                            let photo = dict["photo"] ?? ""
                            let speciesName = dict["speciesName"] ?? ""
                            let caption = dict["caption"] ?? ""
                            let date = dateFormatter.date(from: dict["datePosted"] ?? "") ?? Date()
                            return FishPost(id: uuid, photo: photo, speciesName: speciesName, caption: caption, datePosted: date)
                        }
                    } else {
                        user.fishOfFamePosts = []
                    }

                    user.speciesStore.update(
                        speciesList: data["species list"] as? [String:[[String:String]]] ?? [:],
                        clamPoints: data["clampoints"] as? Int ?? 0,
                        weekSpecies: nil,
                        weekPoints: user.speciesStore.catchOfTheWeekPoints
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
    
    /// Reserves a username in the public `usernames` collection.
    func reserveUsername(_ username: String, uid: String, email: String) async -> Bool {
        let lowercased = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let ref = db.collection("usernames").document(lowercased)
         
        do {
            try await ref.setData([
                "uid": uid,
                "email": email,
                "username": username
            ])
            return true
        } catch {
            print("Error reserving username '\(username)': \(error)")
            return false
        }
    }
    
    func fetchUsers(byIds ids: [String]) async -> [Friend] {
        guard !ids.isEmpty else { return [] }
        var fetchedFriends: [Friend] = []
         
        do {
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
                    isOnline: true
                )
                fetchedFriends.append(friend)
            }
        } catch {
            print("Error fetching friends: \(error.localizedDescription)")
        }
        return fetchedFriends
    }
     
    /// Looks up a user by username via the public `usernames` mapping first,
    /// with a robust fallback query directly against the `users` collection for older accounts.
    func findUserByUsername(_ username: String) async -> (id: String, name: String, profilePic: String)? {
        var queryClean = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if queryClean.hasPrefix("@") {
            queryClean.removeFirst()
        }
         
        do {
            // 1. Try public usernames mapping first
            let mappingDoc = try await db.collection("usernames").document(queryClean).getDocument()
            if mappingDoc.exists, let mappingData = mappingDoc.data(), let uid = mappingData["uid"] as? String {
                let actualName = mappingData["username"] as? String ?? username
                
                // Try to grab their profile pic from their user doc if accessible
                var profilePic = "fisherman"
                if let userDoc = try? await db.collection("users").document(uid).getDocument(),
                   let userData = userDoc.data(),
                   let pic = userData["profile picture"] as? String {
                    profilePic = pic
                }
                
                return (id: uid, name: actualName, profilePic: profilePic)
            }
            
            // 2. Fallback: Query users collection directly (for older accounts lacking a usernames mapping doc)
            let userSnapshot = try await db.collection("users")
                .whereField("username_lowercase", isEqualTo: queryClean)
                .limit(to: 1)
                .getDocuments()
            
            if let doc = userSnapshot.documents.first {
                let data = doc.data()
                let actualName = data["username"] as? String ?? username
                let profilePic = data["profile picture"] as? String ?? "fisherman"
                return (id: doc.documentID, name: actualName, profilePic: profilePic)
            }
        } catch {
            print("Error finding user: \(error)")
        }
        return nil
    }
    
    func fetchFriendProfile(userId: String) async -> User? {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                let friendUser = User(id: userId, email: data["email"] as? String ?? "")
                await MainActor.run {
                    friendUser.username = data["username"] as? String ?? ""
                    friendUser.email = data["email"] as? String ?? ""
                    friendUser.profilePicture = data["profile picture"] as? String ?? ""
                     
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    if let rawPosts = data["fish of fame posts"] as? [[String: String]] {
                        friendUser.fishOfFamePosts = rawPosts.map { dict in
                            let idString = dict["id"] ?? ""
                            let uuid = UUID(uuidString: idString) ?? UUID()
                            let photo = dict["photo"] ?? ""
                            let speciesName = dict["speciesName"] ?? ""
                            let caption = dict["caption"] ?? ""
                            let date = dateFormatter.date(from: dict["datePosted"] ?? "") ?? Date()
                            return FishPost(id: uuid, photo: photo, speciesName: speciesName, caption: caption, datePosted: date)
                        }
                    }
                     
                    friendUser.speciesStore.update(
                        speciesList: data["species list"] as? [String:[[String:String]]] ?? [:],
                        clamPoints: data["clampoints"] as? Int ?? 0,
                        weekSpecies: nil,
                        weekPoints: data["week points"] as? Int ?? 100
                    )
                    friendUser.aquarium.loadUpdate(fishArr: data["aquarium fish"] as? [[String:String]] ?? [])
                }
                return friendUser
            }
        } catch {
            print("Error fetching friend profile: \(error)")
        }
        return nil
    }

    func acceptFriendRequest(senderId: String, currentUserId: String) async {
        do {
            let currentUserRef = db.collection("users").document(currentUserId)
            let senderRef = db.collection("users").document(senderId)

            try await currentUserRef.updateData([
                "incoming_requests": FieldValue.arrayRemove([senderId]),
                "friends": FieldValue.arrayUnion([senderId])
            ])

            try await senderRef.updateData([
                "outgoing_requests": FieldValue.arrayRemove([currentUserId]),
                "friends": FieldValue.arrayUnion([currentUserId])
            ])
            print("Friend request accepted.")
        } catch {
            print("Error accepting friend request: \(error)")
        }
    }

    func declineFriendRequest(senderId: String, currentUserId: String) async {
        do {
            let currentUserRef = db.collection("users").document(currentUserId)
            let senderRef = db.collection("users").document(senderId)

            try await currentUserRef.updateData([
                "incoming_requests": FieldValue.arrayRemove([senderId])
            ])
            try await senderRef.updateData([
                "outgoing_requests": FieldValue.arrayRemove([currentUserId])
            ])
            print("Friend request declined.")
        } catch {
            print("Error declining friend request: \(error)")
        }
    }
    
    func removeFriend(friendId: String, currentUserId: String) async {
        do {
            let currentUserRef = db.collection("users").document(currentUserId)
            let friendRef = db.collection("users").document(friendId)

            try await currentUserRef.updateData([
                "friends": FieldValue.arrayRemove([friendId])
            ])
            try await friendRef.updateData([
                "friends": FieldValue.arrayRemove([currentUserId])
            ])
            print("Friend successfully removed.")
        } catch {
            print("Error removing friend: \(error)")
        }
    }
    
    func sendFriendRequest(targetUserId: String, currentUserId: String) async {
            do {
                let currentUserRef = db.collection("users").document(currentUserId)
                let targetUserRef = db.collection("users").document(targetUserId)

                // Explicitly add target to current user's OUTGOING and ensure they are NOT in incoming
                try await currentUserRef.updateData([
                    "outgoing_requests": FieldValue.arrayUnion([targetUserId]),
                    "incoming_requests": FieldValue.arrayRemove([targetUserId])
                ])
                
                // Explicitly add current user to target user's INCOMING and ensure they are NOT in outgoing
                try await targetUserRef.updateData([
                    "incoming_requests": FieldValue.arrayUnion([currentUserId]),
                    "outgoing_requests": FieldValue.arrayRemove([currentUserId])
                ])
                
                print("Friend request sent successfully from \(currentUserId) to \(targetUserId)")
            } catch {
                print("Error sending friend request: \(error)")
            }
        }
    

    func cancelFriendRequest(targetUserId: String, currentUserId: String) async {
        do {
            try await db.collection("users").document(currentUserId).updateData([
                "outgoing_requests": FieldValue.arrayRemove([targetUserId])
            ])
            try await db.collection("users").document(targetUserId).updateData([
                "incoming_requests": FieldValue.arrayRemove([currentUserId])
            ])
            print("Friend request cancelled successfully.")
        } catch {
            print("Error cancelling friend request: \(error)")
        }
    }
}

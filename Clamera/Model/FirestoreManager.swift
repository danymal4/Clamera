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
     
    func findUserByUsername(_ username: String) async -> (id: String, name: String, profilePic: String)? {
        let queryClean = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
         
        do {
            let snapshot = try await db.collection("users")
                .whereField("username_lowercase", isEqualTo: queryClean)
                .limit(to: 1)
                .getDocuments()
                 
            if let doc = snapshot.documents.first {
                let data = doc.data()
                let actualUsername = data["username"] as? String ?? username
                let profilePic = data["profile picture"] as? String ?? "fisherman"
                return (id: doc.documentID, name: actualUsername, profilePic: profilePic)
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
            try await db.collection("users").document(currentUserId).updateData([
                "outgoing_requests": FieldValue.arrayUnion([targetUserId])
            ])
            try await db.collection("users").document(targetUserId).updateData([
                "incoming_requests": FieldValue.arrayUnion([currentUserId])
            ])
            print("Friend request sent successfully.")
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

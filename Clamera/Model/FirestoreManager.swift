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

    /// Saves a single catch as its own small document in the user's
    /// catches subcollection, instead of embedding it in the main user
    /// document — this is what keeps the main document safely under
    /// Firestore's 1 MiB per-document limit no matter how many fish
    /// someone catches over time.
    func saveFishCatch(_ fish: Fish, forUser uid: String) async {
        guard !uid.isEmpty else { return }
        do {
            try await db.collection("users").document(uid)
                .collection("catches").document(fish.id.uuidString)
                .setData(fish.getDictionary())
        } catch {
            print("Error saving fish catch: \(error)")
        }
    }

    /// Fetches all of a user's catches from the subcollection, grouped by
    /// species name — ready to feed directly into SpeciesStore.update(...).
    func fetchFishCatches(forUser uid: String) async -> [String: [[String: String]]] {
        guard !uid.isEmpty else { return [:] }
        var grouped: [String: [[String: String]]] = [:]
        do {
            let snapshot = try await db.collection("users").document(uid).collection("catches").getDocuments()
            for doc in snapshot.documents {
                var stringDict: [String: String] = [:]
                for (key, value) in doc.data() {
                    stringDict[key] = value as? String ?? "\(value)"
                }
                let speciesName = stringDict["speciesName"] ?? ""
                guard !speciesName.isEmpty else { continue }
                grouped[speciesName, default: []].append(stringDict)
            }
        } catch {
            print("Error fetching fish catches: \(error)")
        }
        return grouped
    }

    func saveUser(user: User) async {
        guard !user.id.isEmpty else { return }
        
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

            var userData: [String: Any] = [
                "username": user.username,
                "username_lowercase": user.username.lowercased(),
                "email": user.email,
                "profile picture": user.profilePicture,
                // Catches now live in the "catches" subcollection instead —
                // explicitly clear the old embedded field so oversized legacy
                // documents shrink back down to a safe size.
                "species list": FieldValue.delete(),
                "clampoints": user.speciesStore.totalClamPoints,
                "aquarium fish": user.aquarium.save(),
                "fish of fame posts": fishOfFameDicts,
                "friends": user.friends,
                "incoming_requests": user.incomingRequests,
                "outgoing_requests": user.outgoingRequests,
                "unlocked shop items": Array(user.unlockedShopItems),
                "login_streak": user.loginStreak,
                "catch_of_the_week_claimed_week": user.speciesStore.catchOfTheWeekClaimedWeek
            ]

            if let lastLogin = user.lastLoginDate {
                userData["last_login_date"] = dateFormatter.string(from: lastLogin)
            }

            if let lastDiscount = user.lastDailyDiscountDate {
                userData["last_daily_discount_date"] = dateFormatter.string(from: lastDiscount)
            }

            try await db.collection("users").document(user.id).setData(userData, merge: true)
            print("user saved successfully for uid: \(user.id)")
        } catch {
            print("Error saving user: \(error)")
        }
    }

    func fetchUser(user: User) async {
        guard !user.id.isEmpty else { return }
        
        do {
            let document = try await db.collection("users").document(user.id).getDocument()

            guard let data = document.data() else {
                print("user fetched successfully for uid: \(user.id) (no data)")
                return
            }

            await MainActor.run {
                user.username = data["username"] as? String ?? ""
                user.email = data["email"] as? String ?? ""
                user.profilePicture = data["profile picture"] as? String ?? ""
                user.friends = data["friends"] as? [String] ?? []
                user.incomingRequests = data["incoming_requests"] as? [String] ?? []
                user.outgoingRequests = data["outgoing_requests"] as? [String] ?? []
                user.unlockedShopItems = Set(data["unlocked shop items"] as? [String] ?? [])
                user.loginStreak = data["login_streak"] as? Int ?? 1
                user.speciesStore.catchOfTheWeekClaimedWeek = data["catch_of_the_week_claimed_week"] as? Int ?? 0
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                if let lastLoginStr = data["last_login_date"] as? String {
                    user.lastLoginDate = dateFormatter.date(from: lastLoginStr)
                }

                if let lastDiscountStr = data["last_daily_discount_date"] as? String {
                    user.lastDailyDiscountDate = dateFormatter.date(from: lastDiscountStr)
                }

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

                user.aquarium.loadUpdate(fishArr: data["aquarium fish"] as? [[String:String]] ?? [])

                // Evaluate daily login streak once remote data has been retrieved
                user.checkLoginStreak()
            }

            // One-time migration: older accounts (including this one, based on
            // the size-limit error) still have catches embedded directly in the
            // user document under "species list". Move any of those into the
            // new catches subcollection, then clear the field so the main
            // document shrinks back to a safe size.
            if let legacySpeciesList = data["species list"] as? [String: [[String: String]]], !legacySpeciesList.isEmpty {
                for (_, fishDicts) in legacySpeciesList {
                    for fishDict in fishDicts where !fishDict.isEmpty {
                        let fish = Fish(dictionary: fishDict)
                        await saveFishCatch(fish, forUser: user.id)
                    }
                }
                await saveUser(user: user) // writes now explicitly delete the oversized legacy field
                print("Migrated legacy embedded catches to subcollection for uid: \(user.id)")
            }

            let groupedCatches = await fetchFishCatches(forUser: user.id)
            await MainActor.run {
                user.speciesStore.update(
                    speciesList: groupedCatches,
                    clamPoints: data["clampoints"] as? Int ?? 0,
                    weekSpecies: nil,
                    weekPoints: user.speciesStore.catchOfTheWeekPoints
                )
            }

            print("user fetched successfully for uid: \(user.id)")
        } catch {
            print("Error fetching user: \(error)")
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

    /// Checks if a username is already taken by another user.
    func isUsernameAvailable(_ username: String, currentUserId: String) async -> Bool {
        let clean = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !clean.isEmpty else { return false }

        do {
            let doc = try await db.collection("usernames").document(clean).getDocument()
            if doc.exists {
                if let uid = doc.data()?["uid"] as? String, uid == currentUserId {
                    return true
                }
                return false
            }
            return true
        } catch {
            print("Error verifying username availability: \(error)")
            return false
        }
    }

    /// Validates uniqueness and atomically updates username across Firestore and the user instance
    func changeUsername(newUsername: String, user: User) async -> (success: Bool, message: String) {
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()

        guard trimmed.count >= 3 else {
            return (false, "Username must be at least 3 characters.")
        }
        guard trimmed.count <= 20 else {
            return (false, "Username cannot exceed 20 characters.")
        }
        guard trimmed.range(of: "^[a-zA-Z0-9_.]+$", options: .regularExpression) != nil else {
            return (false, "Usernames can only include letters, numbers, underscores, and periods.")
        }

        let isAvailable = await isUsernameAvailable(trimmed, currentUserId: user.id)
        guard isAvailable else {
            return (false, "That username is already taken.")
        }

        let oldLowercased = user.username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        do {
            try await db.collection("usernames").document(lowercased).setData([
                "uid": user.id,
                "email": user.email,
                "username": trimmed
            ])

            try await db.collection("users").document(user.id).updateData([
                "username": trimmed,
                "username_lowercase": lowercased
            ])

            if !oldLowercased.isEmpty && oldLowercased != lowercased {
                try? await db.collection("usernames").document(oldLowercased).delete()
            }

            await MainActor.run {
                user.username = trimmed
            }

            return (true, "Username successfully updated!")
        } catch {
            return (false, "Error updating username: \(error.localizedDescription)")
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
     
    func findUserByUsername(_ username: String) async -> (id: String, name: String, profilePic: String)? {
        var queryClean = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if queryClean.hasPrefix("@") {
            queryClean.removeFirst()
        }
         
        do {
            let mappingDoc = try await db.collection("usernames").document(queryClean).getDocument()
            if mappingDoc.exists, let mappingData = mappingDoc.data(), let uid = mappingData["uid"] as? String {
                let actualName = mappingData["username"] as? String ?? username
                
                var profilePic = "fisherman"
                if let userDoc = try? await db.collection("users").document(uid).getDocument(),
                   let userData = userDoc.data(),
                   let pic = userData["profile picture"] as? String {
                    profilePic = pic
                }
                
                return (id: uid, name: actualName, profilePic: profilePic)
            }
            
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

                let groupedCatches = await fetchFishCatches(forUser: userId)

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
                        speciesList: groupedCatches,
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

            try await currentUserRef.updateData([
                "outgoing_requests": FieldValue.arrayUnion([targetUserId]),
                "incoming_requests": FieldValue.arrayRemove([targetUserId])
            ])
            
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

    // MARK: - Clam Points Gifting
    enum GiftError: LocalizedError {
        case insufficientFunds
        case userNotFound
        case selfGiftingNotAllowed
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .insufficientFunds: return "You do not have enough Clam Points to send this gift."
            case .userNotFound: return "Recipient user could not be found."
            case .selfGiftingNotAllowed: return "You cannot gift Clam Points to yourself."
            case .invalidAmount: return "Please enter a valid amount greater than 0."
            }
        }
    }

    func giftClamPoints(from sender: User, toRecipientId recipientId: String, amount: Int) async throws {
        guard amount > 0 else { throw GiftError.invalidAmount }
        guard sender.id != recipientId else { throw GiftError.selfGiftingNotAllowed }

        let senderRef = db.collection("users").document(sender.id)
        let recipientGiftRef = db.collection("users").document(recipientId).collection("pendingGifts").document()

        _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let senderDoc: DocumentSnapshot
            do {
                senderDoc = try transaction.getDocument(senderRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let senderPoints = senderDoc.data()?["clampoints"] as? Int ?? sender.speciesStore.totalClamPoints
            guard senderPoints >= amount else {
                errorPointer?.pointee = NSError(
                    domain: "ClameraGifting",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: GiftError.insufficientFunds.localizedDescription]
                )
                return nil
            }

            transaction.updateData(["clampoints": senderPoints - amount], forDocument: senderRef)

            let giftData: [String: Any] = [
                "id": recipientGiftRef.documentID,
                "senderUID": sender.id,
                "senderUsername": sender.username.isEmpty ? "A Fellow Angler" : sender.username,
                "amount": amount,
                "timestamp": FieldValue.serverTimestamp()
            ]
            transaction.setData(giftData, forDocument: recipientGiftRef)

            return nil
        })

        await MainActor.run {
            sender.speciesStore.totalClamPoints -= amount
        }
    }
    
}

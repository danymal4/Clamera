//
//  User.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/3/26.
//

import SwiftUI

class User: ObservableObject {
    @Published var id: String
    @Published var username: String
    @Published var email: String
    @Published var profilePicture: String
    @Published var aquarium: AquariumFishList
    @Published var speciesStore: SpeciesStore
    @Published var aquariumState: AquariumState
    @Published var leaderboardUser: LeaderboardUser
    @Published var fishOfFamePosts: [FishPost] = []
    
    // Friends & Requests Tracking
    @Published var friends: [String] = []
    @Published var incomingRequests: [String] = []
    @Published var outgoingRequests: [String] = []
    
    // Shop & Progression Additions
    @Published var loginStreak: Int = 1
    @Published var lastLoginDate: Date? = nil
    @Published var lastDailyDiscountDate: Date? = nil
    @Published var unlockedShopItems: Set<String> = []

    // In-memory only — NEVER persisted to Firestore. Captured only at the
    // moment the user actually types their password (sign up, sign in, or
    // change password), since that's the only time the app legitimately
    // has it. Resets to nil on a fresh app launch with no re-entry.
    @Published var passwordLength: Int? = nil

    init(id: String = "", username: String = "",
         email: String = "default@default.com",
         profilePicture: String = "fisherman",
         aquarium: AquariumFishList = AquariumFishList(),
         speciesStore: SpeciesStore = SpeciesStore(),
         aquariumState: AquariumState = AquariumState()) {

        self.id = id
        self.username = username
        self.email = email
        self.profilePicture = profilePicture
        self.aquarium = aquarium
        self.speciesStore = speciesStore
        self.aquariumState = aquariumState
        self.leaderboardUser = LeaderboardUser(name: username, points: speciesStore.totalClamPoints)
    }
    
    @discardableResult
    func checkLoginStreak() -> Bool {
        let calendar = Calendar.current
        let today = Date()
         
        guard let lastLogin = lastLoginDate else {
            // First recorded session
            self.loginStreak = 1
            self.lastLoginDate = today
            return true
        }
         
        if calendar.isDateInToday(lastLogin) {
            // Already checked in today; no changes needed
            return false
        } else if calendar.isDateInYesterday(lastLogin) {
            // Logged in on consecutive day -> advance streak
            self.loginStreak += 1
            self.lastLoginDate = today
            return true
        } else {
            // Missed a day or more -> reset streak
            self.loginStreak = 1
            self.lastLoginDate = today
            return true
        }
    }
    
    var shopDiscountPercentage: Double {
        let calculated = Double(loginStreak) * 1.0
        return min(calculated, 100.0)
    }
}

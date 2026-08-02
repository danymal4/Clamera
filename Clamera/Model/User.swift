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
    
    // ADD THIS: Store friends' user IDs
    @Published var friends: [String] = []
    
    // Shop & Progression Additions
    @Published var loginStreak: Int = 1
    @Published var lastLoginDate: Date? = nil
    @Published var unlockedShopItems: Set<String> = []
    
    let fishingUsernames = [
        "FishHunter5", "AnglerAce", "ReelMaster", "HookedUp", "BassBoss",
        "TroutTrooper", "CastingKing", "LureLegend", "SalmonSeeker", "CatchCraze",
        "FinFanatic", "DeepSeaDave", "RiverRanger", "OceanObserver", "BaitBandit",
        "TackleTitan", "MarlinManiac", "GuppyGuru", "HookLine", "DriftDude",
        "SnapperSniper", "PikePirate", "RodRuler", "ChumChampion", "GillGrinder",
        "FisherFrenzy", "AnglingAce", "BassBuster", "CodCommander", "ReelRanger",
        "SeaSnatcher", "MinnowMaster", "TroutTracker", "HookerHustler", "BaitBrawler",
        "SalmonSage", "CatchCaptain", "LureLover", "OceanOutlaw", "FinFinder",
        "DriftKing", "TackleTamer", "GuppyGlider", "MarlinMaven", "ReelReaper",
        "PikePatrol", "SnapperSurfer", "RodRider", "ChumChaser", "FishFiend"
    ]

    init(id: String = "", username: String? = nil,
         email: String = "default@default.com",
         profilePicture: String = "fisherman",
         aquarium: AquariumFishList = AquariumFishList(),
         speciesStore: SpeciesStore = SpeciesStore(),
         aquariumState: AquariumState = AquariumState()) {

        let finalUsername = username ?? fishingUsernames.randomElement() ?? "FishHunter5"
        self.id = id
        self.username = finalUsername
        self.email = email
        self.profilePicture = profilePicture
        self.aquarium = aquarium
        self.speciesStore = speciesStore
        self.aquariumState = aquariumState
        self.leaderboardUser = LeaderboardUser(name: finalUsername, points: speciesStore.totalClamPoints)
        
        // Check and calibrate login metrics upon initialization
        checkLoginStreak()
    }
    
    // MARK: - Login Streak Engine
    func checkLoginStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let lastLogin = lastLoginDate else {
            // First time ever logging in
            self.loginStreak = 1
            self.lastLoginDate = today
            return
        }
        
        if calendar.isDateInToday(lastLogin) {
            // Already logged in today, streak stays the same
            return
        } else if calendar.isDateInYesterday(lastLogin) {
            // Logged in exactly yesterday! Increment streak
            self.loginStreak += 1
            self.lastLoginDate = today
        } else {
            // Missed a day or more, reset streak
            self.loginStreak = 1
            self.lastLoginDate = today
        }
    }
    
    /// Calculates discount tier from the login streak (caps out at 20% max discount)
    var shopDiscountPercentage: Double {
        let calculated = Double(loginStreak) * 1.0 // 1% per day of streak
        return min(calculated, 20.0)
    }
}

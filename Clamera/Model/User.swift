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
        
        checkLoginStreak()
    }
    
    func checkLoginStreak() {
        let calendar = Calendar.current
        let today = Date()
         
        guard let lastLogin = lastLoginDate else {
            self.loginStreak = 1
            self.lastLoginDate = today
            return
        }
         
        if calendar.isDateInToday(lastLogin) {
            return
        } else if calendar.isDateInYesterday(lastLogin) {
            self.loginStreak += 1
            self.lastLoginDate = today
        } else {
            self.loginStreak = 1
            self.lastLoginDate = today
        }
    }
    
    var shopDiscountPercentage: Double {
        let calculated = Double(loginStreak) * 1.0
        return min(calculated, 100.0)
    }
}

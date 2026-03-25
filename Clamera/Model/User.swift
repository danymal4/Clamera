//
//  User.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/3/26.
//

import SwiftUI

class User: ObservableObject {
    @Published var username: String
    @Published var email: String
    @Published var password: String
    @Published var profilePicture: String
    @Published var aquarium: AquariumFishList
    @Published var speciesStore: SpeciesStore
    @Published var aquariumState: AquariumState

    @Published var leaderboardUser: LeaderboardUser

    let fishingUsernames = [
        "FishHunter5", "AnglerAce", "ReelMaster", "HookedUp", "BassBoss",
        "TroutTrooper", "CastingKing", "LureLegend", "SalmonSeeker", "CatchCraze",
        "FinFanatic", "DeepSeaDave", "RiverRanger", "OceanObserver", "BaitBandit",
        "TackleTitan", "MarlinManiac", "GuppyGuru", "HookLine", "DriftDude",
        "SnapperSniper", "PikePirate", "RodRuler", "ChumChampion", "GillGrinder",
        "FisherFrenzy", "AnglingAce", "BassBuster", "CodCommander", "ReelRanger",
        "SeaSnatcher", "MinnowMaster", "TroutTracker", "HookHustler", "BaitBrawler",
        "SalmonSage", "CatchCaptain", "LureLover", "OceanOutlaw", "FinFinder",
        "DriftKing", "TackleTamer", "GuppyGlider", "MarlinMaven", "ReelReaper",
        "PikePatrol", "SnapperSurfer", "RodRider", "ChumChaser", "FishFiend"
    ]

    init(username: String? = nil,
         email: String = "default@default.com",
         password: String = "DefaultPassword",
         profilePicture: String = "fisherman",
         aquarium: AquariumFishList = AquariumFishList(),
         speciesStore: SpeciesStore = SpeciesStore(),
         aquariumState: AquariumState = AquariumState()) {


        let finalUsername = username ?? fishingUsernames.randomElement() ?? "FishHunter5"
        self.username = finalUsername
        self.email = email
        self.password = password
        self.profilePicture = profilePicture
        self.aquarium = aquarium
        self.speciesStore = speciesStore
        self.aquariumState = aquariumState

      
        self.leaderboardUser = LeaderboardUser(name: finalUsername, points: speciesStore.totalClamPoints)
    }
}

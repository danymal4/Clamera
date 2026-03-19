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
    
    var leaderboardUser: LeaderboardUser {
        return LeaderboardUser(name: self.username, points: speciesStore.totalClamPoints)
    }
    
    init(username: String = "FishHunter5",
         email: String = "default@default.com",
         password: String = "DefaultPassword",
         profilePicture: String = "fisherman",
         aquarium: AquariumFishList = AquariumFishList(),
         speciesStore: SpeciesStore = SpeciesStore(),
         aquariumState: AquariumState = AquariumState()) {
        self.username = username
        self.email = email
        self.password = password
        self.profilePicture = profilePicture
        self.aquarium = aquarium
        self.speciesStore = speciesStore
        self.aquariumState = aquariumState
    }
}

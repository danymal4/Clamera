//
//  User.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/3/26.
//

import SwiftUI

class User: ObservableObject {
    @Published var username: String
    @Published var aquarium: AquariumFishList
    @Published var speciesStore: SpeciesStore
    @Published var aquariumState: AquariumState
    
    var leaderboardUser: LeaderboardUser {
        return LeaderboardUser(name: self.username, points: speciesStore.totalClamPoints)
    }
    
    init(username: String = "FishHunter5",
         aquarium: AquariumFishList = AquariumFishList(),
         speciesStore: SpeciesStore = SpeciesStore(),
         aquariumState: AquariumState = AquariumState()) {
        self.username = username
        self.aquarium = aquarium
        self.speciesStore = speciesStore
        self.aquariumState = aquariumState
    }
}

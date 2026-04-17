//
//  ClameraApp.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

@main
struct ClameraApp: App {
    
    @StateObject var aquarium = AquariumFishList()
    @StateObject var speciesStore = SpeciesStore()
    @StateObject var aquariumState = AquariumState()
    @StateObject var user = User()
    @StateObject var leaderboard = LeaderboardData()
    
    var body: some Scene {
        WindowGroup {
            
              
                HomerView()   // ← just reference it
                    .environmentObject(aquarium)
                    .environmentObject(speciesStore)
                    .environmentObject(aquariumState)
                    .environmentObject(user)
                    .environmentObject(leaderboard)
        }
    }
}

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

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomerView()   // ← just reference it
                    .environmentObject(aquarium)
                    .environmentObject(speciesStore)
                    .environmentObject(aquariumState)
            }
        }
    }
}

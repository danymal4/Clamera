//
//  User.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/3/26.
//

import SwiftUI

class User: ObservableObject {
    @Published var aquarium: AquariumFishList
    @Published var speciesStore: SpeciesStore
    @Published var aquariumState: AquariumState
    
    init(aquarium: AquariumFishList = AquariumFishList(),
         speciesStore: SpeciesStore = SpeciesStore(),
         aquariumState: AquariumState = AquariumState()) {
        self.aquarium = aquarium
        self.speciesStore = speciesStore
        self.aquariumState = aquariumState
    }
}

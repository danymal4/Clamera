//
//  AquariumFishList.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

final class AquariumFishList: ObservableObject {
    @Published var fish: [AquariumFish]
    @Published var refreshID = false
    
    init() {
        self.fish = [
            AquariumFish(
                imageName: "clownfishIcon",
                size: CGSize(width: 80, height: 50),
                horizontalRange: -137...137,
                verticalRange: -130...130,
                swimDuration: 8,
                phaseOffset: 0,
                isActive: true,
                isShown: true
            ),
            AquariumFish(
                imageName: "pufferIcon",
                size: CGSize(width: 70, height: 45),
                horizontalRange: -140...120,
                verticalRange: -140...140,
                swimDuration: 10,
                phaseOffset: 1,
                isActive: true,
                isShown: true
            ),
            AquariumFish(
                imageName: "grouperIcon",
                size: CGSize(width: 90, height: 55),
                horizontalRange: -120...148,
                verticalRange: -120...120,
                swimDuration: 12,
                phaseOffset: 2,
                isActive: true,
                isShown: true
            )
        ]
    }
    
    func refresh() {
        refreshID.toggle() // just flips true/false to trigger a redraw
    }

    func checkAll() -> Bool {
      var ifAllActive = true
        for AquariumFish in fish {
            if !AquariumFish.isActive {
                ifAllActive = false
            }
        }
   return ifAllActive
    }
    
    
    func updateSpeed(for fish: AquariumFish, to newDuration: Double) {
        fish.swimDuration = newDuration
    }
    
    func updateSize(for fish: AquariumFish, to newSize: CGSize) {
        fish.size = newSize
    }
    
    func toggleActive(for fish: AquariumFish) {
        fish.isActive.toggle()
    }

    
    func toggleShown(for fish: AquariumFish) {
        fish.isShown.toggle()
    }
    
    func fishCount() -> Int {
        fish.count
    }
    
    func removeFish(with imageName: String) {
        if let index = fish.firstIndex(where: { $0.imageName == imageName && $0.isActive }) {
            fish[index].isActive = false
        }
    }
    
    func addFish(with imageName: String, maxActive: Int = 3) {
        // Count currently active fish
        let activeCount = fish.filter { $0.isActive }.count


        guard activeCount < maxActive else { return }

        // Find the first inactive fish
        if let index = fish.firstIndex(where: { !$0.isActive }) {
            let oldFish = fish[index]
            oldFish.imageName = imageName   
            oldFish.isActive = true
            oldFish.isShown = true
           
        }
    }

    
    

    
    func toggleAll() {
        withAnimation(.easeInOut(duration: 0.3)) {
            for fish in fish {
                fish.isActive = false
            }
        }
    }

    
}

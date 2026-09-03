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
                imageName: "Summer FlounderIcon",
                size: CGSize(width: 180, height: 150),
                horizontalRange: -137...137,
                verticalRange: -130...130,
                swimDuration: 8,
                phaseOffset: 0,
                isActive: true,
                isShown: true
            ),
            AquariumFish(
                imageName: "Atlantic Bluefin TunaIcon",
                size: CGSize(width: 170, height: 145),
                horizontalRange: -140...120,
                verticalRange: -140...140,
                swimDuration: 10,
                phaseOffset: 1,
                isActive: true,
                isShown: true
            ),
            AquariumFish(
                imageName: "OpahIcon",
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
    
    func loadUpdate(fishArr: [[String:String]]) {
        for i in 0..<fishArr.count {
            if fishArr[i] != [:] && i < fish.count {
                fish[i].update(from: fishArr[i])
            }
        }
    }
    
    func save() -> [[String:String]] {
        var arr: [[String:String]] = []
        for f in fish {
            arr.append(f.getDictionary())
        }
        return arr
    }
    
    func refresh() {
        refreshID.toggle()
    }

    func checkAll() -> Bool {
        for fish in fish {
            if !fish.isActive { return false }
        }
        return true
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
    
    func removeFish(with imageName: String, targetSize: CGSize) {
        let candidates = fish.enumerated().filter { $0.element.isActive && $0.element.imageName == imageName }

        if let closest = candidates.min(by: { a, b in
            let distanceA = hypot(a.element.size.width - targetSize.width, a.element.size.height - targetSize.height)
            let distanceB = hypot(b.element.size.width - targetSize.width, b.element.size.height - targetSize.height)
            return distanceA < distanceB
        }) {
            fish[closest.offset].isActive = false
        }
    }
    
    func addFish(with imageName: String, speciesID: String, size: CGSize, maxActive: Int = 3) {
        let activeCount = fish.filter { $0.isActive }.count
        guard activeCount < maxActive else { return }

        if let index = fish.firstIndex(where: { !$0.isActive }) {
            let oldFish = fish[index]
            oldFish.imageName = imageName
            oldFish.isActive = true
            oldFish.isShown = true
            oldFish.speciesID = speciesID
            oldFish.size = size
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

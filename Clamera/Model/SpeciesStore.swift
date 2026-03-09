//
//  SpeciesStore.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

final class SpeciesStore: ObservableObject {
    @Published var speciesList: [Species] = []
    @Published var totalClamPoints: Int = 0
    

    @Published var catchOfTheWeek: Species?
    @Published var catchOfTheWeekPoints: Int = Int.random(in: 30...40) * 5
    
    init() {
        loadFromJSON()
        assignCatchOfTheWeek()
    }
    
    convenience init(previewSpecies: [Species]) {
        self.init()
        self.speciesList = previewSpecies
        assignCatchOfTheWeek()
    }
    
    private func loadFromJSON() {
        guard let url = Bundle.main.url(forResource: "fish_data", withExtension: "json") else {
            print("Couldnt find fish_data.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([FishData].self, from: data)
            
        
            self.speciesList = decoded.map { fish in
                Species(
                    name: fish.CommonName,
                    imageName: fish.Image,
                    fishList: []
                )
            }
            
            print("Loaded \(speciesList.count) species")
        } catch {
            print("JSON error:", error)
        }
    }
    
  
    func assignCatchOfTheWeek() {
        let validSpecies = speciesList.filter { species in
            let imageName = "\(species.name)Icon"
            return UIImage(named: imageName) != nil
        }
        
        guard !validSpecies.isEmpty else {
            catchOfTheWeek = nil
            return
        }
        
        catchOfTheWeek = validSpecies.randomElement()
    }
    
   
    func catchOfTheWeekIcon() -> String? {
        guard let species = catchOfTheWeek else { return nil }
        return "\(species.name)Icon"
    }
    

    func calculateClamPoints(
        totalOfSpecies caughtFish: Int,
        totalOtherFish otherFish: Int,
        previousFishDate: Date? = nil
    ) -> Int {
        guard caughtFish > 0 else { return 0 }
        let safeOtherFish = max(otherFish, 0)
        if caughtFish == 1 { return 90 }
        
        let caughtMinRaw = 15 + abs(Double(safeOtherFish - 5) / 3.0)
        let caughtMin = min(caughtMinRaw, 30)
        guard caughtMin > 2 else { return 50 }
        
        let pointsRaw = 50 - Double(caughtFish - 2) * (30 / (caughtMin - 2))
        let speciesPoints = max(pointsRaw, 20)
        
        var timeBonus: Double = 0
        if let prevDate = previousFishDate {
            let daysSincePrevious = Calendar.current.dateComponents([.day], from: prevDate, to: Date()).day ?? 0
            let rawTimeBonus = 12.0 * log(Double(daysSincePrevious) + 1) / log(61.0)
            timeBonus = min(rawTimeBonus, 12.0)
        }
        
        return Int((speciesPoints + timeBonus).rounded())
    }
    
   
    func getSpecies() -> Int {
        speciesList.filter { !$0.fishList.isEmpty }.count
    }
    
    func getFish() -> Int {
        speciesList.reduce(0) { $0 + $1.fishList.count }
    }
    
    func randomPoints() -> Int {
        Int.random(in: 30...40) * 5
    }

    
    func refresh() {
        objectWillChange.send()
    }
}
    
    


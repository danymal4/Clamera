//
//  SpeciesStore.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

final class SpeciesStore: ObservableObject {
    @Published var speciesList: [Species] = []
    @Published var totalClamPoints: Int = 40
    
    @Published var pinnedDisplay: Fish?
    @Published var catchOfTheWeek: Species?
    @Published var catchOfTheWeekPoints: Int = Int.random(in: 30...40) * 5
    @Published var popupType: Int = 0
    
    init() {
       
        // calls all the json logic upon loading
        loadFromJSON()
        assignCatchOfTheWeek()
    }
    
    convenience init(previewSpecies: [Species]) {
        self.init()
        self.speciesList = previewSpecies
        assignCatchOfTheWeek()
    }
    
    
    // declares url from fish data json
    
    private func loadFromJSON() {
        guard let url = Bundle.main.url(forResource: "fish_data", withExtension: "json") else {
            print("Cant find fish data")
            return
        }
        
        do {
        
           // if successful then trys to get data from the url
            
            let data = try Data(contentsOf: url)
            
            // attempts to convert json into an array of fishdata objects (try throws error if neccesary)
            // fish data neeeded to match the json's organization
            let decoded = try JSONDecoder().decode([FishData].self, from: data)
            
        
            // takes the decoded fish data and adds it into speciesList class with the correct format
            self.speciesList = decoded.map { fish in
                Species(
                    name: fish.CommonName,
                    imageName: fish.Image,
                    fishList: []
                )
            }
            
            print("Loaded \(speciesList.count) species")
        } catch {
            
            // do/catch is here to see precise errors
            print("JSON error:", error)
        }
    }
    
    func assignPinnedDisplay() {
        var pinnedFish: [Fish] = []

        for species in speciesList {
            for fish in species.fishList {
                if fish.isPinned {
                    pinnedFish.append(fish)
                }
            }
        }

        pinnedDisplay = pinnedFish.randomElement()
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
    
    


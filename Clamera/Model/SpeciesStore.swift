//
//  SpeciesStore.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI
import Foundation

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
    
    func getWeekCatch() -> [[String:String]] {
        var arr: [[String:String]] = []
        if let sp = catchOfTheWeek {
            arr = sp.getFullArray()
        }
        return arr
    }
    
    func getWeekCatchPoints() -> Int {
        return catchOfTheWeekPoints
    }
    
    func getDictionary() -> [String:[[String:String]]] {
        var species: [String:[[String:String]]] = [:]
        for s in speciesList {
            species.updateValue(s.getArray(), forKey: s.name)
        }
        return species
    }
    
    func update(speciesList:[String:[[String:String]]], clamPoints: Int, weekSpecies: [[String:String]]?, weekPoints: Int) {
        self.totalClamPoints = clamPoints
        for (name, species) in speciesList{
            for i in 0..<self.speciesList.count {
                if self.speciesList[i].name == name && species != [] {
                    self.speciesList[i].update(fishArray: species)
                }
            }
        }
        
        // Recalculates pinned display state properly on data update/fetch
        assignPinnedDisplay()
        
        if let array = weekSpecies {
            catchOfTheWeek = Species(array: array)
        }
        catchOfTheWeekPoints = weekPoints
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
            // Ensure global synchronization happens after loading JSON data
            assignCatchOfTheWeek()
        } catch {
             
            // do/catch is here to see precise errors
            print("JSON error:", error)
        }
    }
    
    func assignPinnedDisplay() {
        var foundPinned: Fish? = nil

        for species in speciesList {
            for fish in species.fishList {
                if fish.isPinned {
                    foundPinned = fish
                    break
                }
            }
            if foundPinned != nil { break }
        }

        pinnedDisplay = foundPinned
    }
    
    func assignCatchOfTheWeek() {
        guard !speciesList.isEmpty else {
            catchOfTheWeek = nil
            return
        }
         
        // Calculate a stable index based on the current calendar week and year globally for all accounts
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
         
        // Combine year and week to create a unique seed for this specific week globally
        let weeklySeed = year * 100 + weekOfYear
        let index = abs(weeklySeed) % speciesList.count
         
        catchOfTheWeek = speciesList[index]
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

    func bestMatchingSpeciesName(for aiPrediction: String) -> String? {
        let prediction = normalizedSpeciesToken(aiPrediction)
        guard !prediction.isEmpty, prediction != "unknown" else { return nil }

        if let exact = speciesList.first(where: { normalizedSpeciesToken($0.name) == prediction }) {
            return exact.name
        }

        if let containsMatch = speciesList.first(where: {
            let normalizedName = normalizedSpeciesToken($0.name)
            return normalizedName.contains(prediction) || prediction.contains(normalizedName)
        }) {
            return containsMatch.name
        }

        let predictionTokens = Set(prediction.split(separator: " ").map(String.init))
        guard !predictionTokens.isEmpty else { return nil }

        let scored = speciesList.map { species -> (name: String, score: Int) in
            let speciesTokens = Set(normalizedSpeciesToken(species.name).split(separator: " ").map(String.init))
            let overlap = predictionTokens.intersection(speciesTokens).count
            return (species.name, overlap)
        }

        guard let best = scored.max(by: { $0.score < $1.score }), best.score > 0 else {
            return nil
        }

        return best.name
    }

    private func normalizedSpeciesToken(_ input: String) -> String {
        input
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func refresh() {
        objectWillChange.send()
    }
}

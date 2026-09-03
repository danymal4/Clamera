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
    @Published var catchOfTheWeekPoints: Int = 180
    @Published var popupType: Int = 0

    // Curated allowlist for Catch of the Week
    private static let catchOfTheWeekAllowedNames: [String] = [
        "Arctic Char",
        "Atoll Butterflyfish",
        "Black Crappie Variant",
        "Black Rockfish",
        "Black Seabass",
        "Blackspot Seabream",
        "Blacktip Shark",
        "Blue Marlin",
        "Blue Rockfish",
        "Blue Triggerfish",
        "Blue-spotted Cornetfish",
        "Bluegill",
        "Blue spine Unicornfish",
        "Bluespot Whiting",
        "Boarfish",
        "Bocaccio Rockfish",
        "Bogue",
        "BogueIcon",
        "Bombay Duck",
        "Brassy Chub",
        "Brook Trout",
        "Brownstripe Red Snapper",
        "Burton’s Mouthbrooder",
        "Burton's Mouthbrooder",
        "Cardinalfish",
        "Catla",
        "Chum Salmon",
        "Common Chub",
        "Common Dentex",
        "Common Dragonet",
        "Common Pandora",
        "Common Porgy",
        "Common Two-banded Seabream",
        "Darkspotted Snake",
        "Darkspotted Snake Eel",
        "Elegant Firefish",
        "Fourfinger Threadfin",
        "Gilthead Seabream",
        "Goldblotch Grouper",
        "Golden Grey Mullet",
        "Golden Redhorse",
        "Golden Tilefish",
        "Greater Amberjack",
        "Green Sunfish",
        "Hooded Wrassel",
        "Hooded Wrasse",
        "Indian Ocean Sweetlips",
        "Indian Whiting",
        "Japanese Horse Mackerel",
        "Japanese Threadfin Bream",
        "Leatherjacket",
        "Leopard Coral Grouper",
        "Longear Sunfish",
        "Longspined Grunt",
        "Mahi Mahi",
        "Manyspined Butterflyfish",
        "Milkfish",
        "Ocean Sunfish",
        "Ocellaris Clownfish",
        "Opah",
        "Orangethroat Darter",
        "Obicular Batfish",
        "Orbicular Batfish",
        "Pacific Cod",
        "Palette Surgeonfish",
        "Palometa",
        "Permit",
        "Peron’s Threadfin Bream",
        "Peron's Threadfin Bream",
        "Picarel",
        "Pinecone Soldierfish",
        "Pink Squirrelfish",
        "Pompano Dolphinfish",
        "Puffer",
        "Pumpkinseed Sunfish",
        "Rainbow Darter",
        "Red Emperor",
        "Red Mullet",
        "Red Snapper",
        "Redear Sunfish",
        "Sailfish",
        "Salmon",
        "Snubnose Pompano",
        "Sockeye Salmon",
        "Southern Kingfish",
        "Spotfin Flying Gurnard",
        "Spotted Catfish",
        "Starspotted Rabbitfish",
        "Striped Pompano",
        "Striped Seabream",
        "Swordfish",
        "Twospot Threadfin",
        "Western Yellowfin Bream",
        "White Seabream",
        "White Trevally",
        "Yellow Perch",
        "Yellowfin Bream",
        "Yellowfin Grouper",
        "Yellowfin Tuna",
        "Yellowtail Amberjack"
    ]
    
    init() {
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
    
    func update(speciesList: [String:[[String:String]]], clamPoints: Int, weekSpecies: [[String:String]]?, weekPoints: Int) {
        self.totalClamPoints = clamPoints
        for (name, species) in speciesList {
            for i in 0..<self.speciesList.count {
                if self.speciesList[i].name == name && species != [] {
                    self.speciesList[i].update(fishArray: species)
                }
            }
        }
        
        assignPinnedDisplay()
        assignCatchOfTheWeek()
    }
    
    private func loadFromJSON() {
        guard let url = Bundle.main.url(forResource: "fish_data", withExtension: "json") else {
            print("Cant find fish data")
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
            assignCatchOfTheWeek()
        } catch {
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
        
        // Build normalized set of allowed names
        let allowedNormalized = Set(SpeciesStore.catchOfTheWeekAllowedNames.map { normalizedSpeciesToken($0) })
        
        // Filter species down to allowed candidates
        let candidatePool = speciesList.filter { species in
            let normalizedName = normalizedSpeciesToken(species.name)
            return allowedNormalized.contains(normalizedName)
        }
        
        // Fallback to full speciesList if JSON names differ significantly
        let poolToSelectFrom = candidatePool.isEmpty ? speciesList : candidatePool
         
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Lock weeks to start on Monday
        
        let now = Date()
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.yearForWeekOfYear, from: now)
         
        // Consistent global seed for the entire 7-day period
        let weeklySeed = year * 100 + weekOfYear
        let index = abs(weeklySeed) % poolToSelectFrom.count
         
        catchOfTheWeek = poolToSelectFrom[index]
        
        // Deterministic points for the week (between 150 and 200)
        let pointSeed = abs(weeklySeed * 31) % 11 // 0...10
        catchOfTheWeekPoints = 150 + (pointSeed * 5)
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

//
//  SpeciesStore.swift
//  Clamera
//
//  Created by Kaes van Dolder on student LM on 3/2/26.
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
    @Published var lastCaughtFishName: String = ""

    /// Persisted marker for which week's Catch of the Week has already been
    /// claimed by this user (stored as the same `weeklySeed` used to pick the
    /// species). 0 means "never claimed." Survives app relaunches via Firestore.
    @Published var catchOfTheWeekClaimedWeek: Int = 0

    /// True if this week's Catch of the Week has already been claimed —
    /// use this (not `catchOfTheWeek == nil`) to decide whether to show the
    /// "come catch me" state vs. the "already claimed" state.
    var isCatchOfTheWeekClaimed: Bool {
        catchOfTheWeekClaimedWeek == currentWeekSeed()
    }

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

    /// The deterministic weekly seed (year * 100 + weekOfYear) used both to
    /// pick this week's Catch of the Week and to mark when it was claimed.
    /// Weeks are locked to start on Monday.
    func currentWeekSeed() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday

        let now = Date()
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.yearForWeekOfYear, from: now)

        return year * 100 + weekOfYear
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
         
        let weeklySeed = currentWeekSeed()
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
        guard !prediction.isEmpty, prediction != "unknown", !speciesList.isEmpty else {
            return nil
        }

        // 1. Direct synonym / popular alternative dictionary
        let commonAliases: [String: String] = [
            "blue tang": "Palette Surgeonfish",
            "regal tang": "Palette Surgeonfish",
            "regal blue tang": "Palette Surgeonfish",
            "paracanthurus hepatus": "Palette Surgeonfish",
            "clown anemonefish": "Ocellaris Clownfish",
            "clownfish": "Ocellaris Clownfish",
            "false percula": "Ocellaris Clownfish",
            "dory": "Palette Surgeonfish",
            "nemo": "Ocellaris Clownfish"
        ]

        if let mapped = commonAliases[prediction] {
            return mapped
        }

        for (alias, canonicalName) in commonAliases {
            if prediction.contains(alias) {
                return canonicalName
            }
        }

        // 2. Exact match
        if let exact = speciesList.first(where: { normalizedSpeciesToken($0.name) == prediction }) {
            return exact.name
        }

        // 3. Substring match
        if let containsMatch = speciesList.first(where: {
            let normalizedName = normalizedSpeciesToken($0.name)
            return normalizedName.contains(prediction) || prediction.contains(normalizedName)
        }) {
            return containsMatch.name
        }

        // 4. Real similarity scoring — combines word-overlap ratio (Jaccard)
        // with whole-string edit-distance similarity, so ties are broken by
        // how close the names actually are, not by array order.
        let predictionTokens = Set(prediction.split(separator: " ").map(String.init))
            .subtracting(["fish", "common", "atlantic", "pacific", "spotted"])

        var bestName: String?
        var bestScore: Double = 0

        for species in speciesList {
            let normalizedName = normalizedSpeciesToken(species.name)
            let speciesTokens = Set(normalizedName.split(separator: " ").map(String.init))

            let unionCount = predictionTokens.union(speciesTokens).count
            let jaccard = unionCount > 0
                ? Double(predictionTokens.intersection(speciesTokens).count) / Double(unionCount)
                : 0

            let editSimilarity = normalizedStringSimilarity(prediction, normalizedName)

            let combinedScore = (jaccard * 0.6) + (editSimilarity * 0.4)

            if combinedScore > bestScore {
                bestScore = combinedScore
                bestName = species.name
            }
        }

        if let bestName, bestScore > 0.2 {
            return bestName
        }

        // 5. Last resort: closest overall spelling in the whole list.
        let closestBySpelling = speciesList.max {
            normalizedStringSimilarity(prediction, normalizedSpeciesToken($0.name))
            < normalizedStringSimilarity(prediction, normalizedSpeciesToken($1.name))
        }

        return closestBySpelling?.name
    }

    private func normalizedSpeciesToken(_ input: String) -> String {
        input
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedStringSimilarity(_ a: String, _ b: String) -> Double {
        let distance = levenshteinDistance(a, b)
        let maxLength = max(a.count, b.count)
        guard maxLength > 0 else { return 1.0 }
        return 1.0 - (Double(distance) / Double(maxLength))
    }

    private func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        var dist = Array(repeating: Array(repeating: 0, count: bChars.count + 1), count: aChars.count + 1)

        for i in 0...aChars.count { dist[i][0] = i }
        for j in 0...bChars.count { dist[0][j] = j }

        guard aChars.count > 0, bChars.count > 0 else { return dist[aChars.count][bChars.count] }

        for i in 1...aChars.count {
            for j in 1...bChars.count {
                if aChars[i - 1] == bChars[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[aChars.count][bChars.count]
    }
    
    func refresh() {
        objectWillChange.send()
    }
}

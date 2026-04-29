import SwiftUI
import Vision

final class SpeciesStore: ObservableObject {
    @Published var speciesList: [Species] = []
    @Published var totalClamPoints: Int = 40
    
    @Published var pinnedDisplay: Fish?
    @Published var catchOfTheWeek: Species?
    @Published var catchOfTheWeekPoints: Int = Int.random(in: 30...40) * 5
    @Published var popupType: Int = 0
    
    init() {
        loadFromJSON()
        assignCatchOfTheWeek()
    }
    
    convenience init(previewSpecies: [Species]) {
        self.init()
        self.speciesList = previewSpecies
        assignCatchOfTheWeek()
    }
    
    func getDictionary() -> [String:[[String:String]]] {
        var species: [String:[[String:String]]] = [:]
        for s in speciesList {
            species.updateValue(s.getArray(), forKey: s.name)
        }
        return species
    }
    
    func update(speciesList:[String:[[String:String]]], clamPoints: Int) {
        self.totalClamPoints = clamPoints
        for (name, species) in speciesList {
            for i in 0..<self.speciesList.count {
                if self.speciesList[i].name == name {
                    self.speciesList[i].update(fishArray: species)
                }
            }
        }
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
                    imageName: fish.Image, // Wikipedia URL
                    fishList: []
                )
            }
            print("Loaded \(speciesList.count) species")
        } catch {
            print("JSON error:", error)
        }
    }
    
    func assignPinnedDisplay() {
        var pinnedFish: [Fish] = []
        for species in speciesList {
            for fish in species.fishList {
                if fish.isPinned { pinnedFish.append(fish) }
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
        
        // Returns the total count of all fish caught across all species
        func getFish() -> Int {
            speciesList.reduce(0) { $0 + $1.fishList.count }
        }
        
        // Returns the count of species that have at least one fish caught
        func getSpecies() -> Int {
            speciesList.filter { !$0.fishList.isEmpty }.count
        }

        // This is the point calculation logic your CatchManageView is looking for
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

        // Simple refresh to tell SwiftUI to redraw views
        func refresh() {
            objectWillChange.send()
        }
}

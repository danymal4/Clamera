import SwiftUI
import Vision

class Species: ObservableObject, Identifiable, Hashable {

    let id: String   // stable ID = species name
    let name: String
    let imageName: String // This holds the Wikipedia URL
    let icon: String

    // This is the "Mathematical Fingerprint" the AI uses to identify the fish
    var featurePrint: VNFeaturePrintObservation? = nil

    @Published var fishList: [Fish]

    var numberOfFish: Int { fishList.count }

    func getFishPhotos() -> [String] {
        fishList.map { $0.photo }
    }

    init(name: String, imageName: String, icon: String = "clownfishIcon", fishList: [Fish] = []) {
        self.id = name
        self.name = name
        self.imageName = imageName
        self.icon = icon
        self.fishList = fishList
    }
    
    func update(fishArray: [[String:String]]) {
        var fishList: [Fish] = []
        for fish in fishArray {
            if fish != [:] {
                fishList.append(Fish(dictionary: fish))
            }
        }
        self.fishList = fishList
    }

    func getArray() -> [[String:String]] {
        var fishArr: [[String:String]] = [[:]]
        for fish in fishList {
            fishArr.append(fish.getDictionary())
        }
        return fishArr
    }

    // MARK: - Hashable
    static func == (lhs: Species, rhs: Species) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

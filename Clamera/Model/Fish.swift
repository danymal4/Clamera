import Foundation
import Vision

class Fish: Identifiable, ObservableObject, Hashable {
    let id = UUID()
    var photo: String
    let speciesName: String
    
    // Optional: Only keep if you want to scan caught fish photos later
    var featurePrint: VNFeaturePrintObservation? = nil
    
    @Published var description: String
    @Published var dateCaught: Date
    @Published var isPinned: Bool
    @Published var isAquarium: Bool
    @Published var isDeleted: Bool
    @Published var fishWeight: Int?

    // Standard Initializer
    init(photo: String,
         speciesName: String,
         description: String = "cool fish I found with sam",
         dateCaught: Date = Date(),
         isPinned: Bool = false,
         isAquarium: Bool = false,
         isDeleted: Bool = false,
         fishWeight: Int? = nil) {
        self.photo = photo
        self.speciesName = speciesName
        self.description = description
        self.dateCaught = dateCaught
        self.isPinned = isPinned
        self.isAquarium = isAquarium
        self.isDeleted = isDeleted
        self.fishWeight = fishWeight
    }

    // Unified Dictionary Initializer
    init(dictionary: [String: String]) {
        // This handles BOTH the Wikipedia JSON keys and your local Save keys
        self.photo = dictionary["Image"] ?? dictionary["photo"] ?? ""
        self.speciesName = dictionary["CommonName"] ?? dictionary["Species"] ?? dictionary["speciesName"] ?? "Unknown"
        self.description = dictionary["description"] ?? "cool fish I found with sam"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.dateCaught = dateFormatter.date(from: dictionary["date"] ?? dictionary["dateCaught"] ?? "") ?? Date()
        
        self.isPinned = Bool(dictionary["isPinned"] ?? "false") ?? false
        self.isDeleted = Bool(dictionary["isDeleted"] ?? "false") ?? false
        self.isAquarium = Bool(dictionary["isAquarium"] ?? "false") ?? false
        
        // Handle weight if it exists in the dictionary
        if let weightString = dictionary["fishWeight"], let weightInt = Int(weightString) {
            self.fishWeight = weightInt
        } else {
            self.fishWeight = nil
        }
    }

    func getDictionary() -> [String : String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return [
            "photo": self.photo,
            "speciesName": self.speciesName,
            "description": self.description,
            "dateCaught": dateFormatter.string(from: self.dateCaught),
            "isPinned": String(isPinned),
            "isDeleted": String(isDeleted),
            "isAquarium": String(isAquarium)
        ]
    }

    // MARK: - Hashable
    static func == (lhs: Fish, rhs: Fish) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // MARK: - Helper
    func getSize() -> CGSize {
        guard let weight = fishWeight else { return CGSize(width: 110, height: 110) }
        let dimension: CGFloat
        switch weight {
        case 0...5: dimension = 20 + CGFloat(weight) / 5 * 22
        case 5...10: dimension = 42 + CGFloat(weight - 5) / 5 * 22
        case 10...20: dimension = 64 + CGFloat(weight - 10) / 10 * 22
        case 20...30: dimension = 86 + CGFloat(weight - 20) / 10 * 22
        case 30...40: dimension = 108 + CGFloat(weight - 30) / 10 * 22
        case 40...50: dimension = 130 + CGFloat(weight - 40) / 10 * 22
        case 50...75: dimension = 152 + CGFloat(weight - 50) / 25 * 22
        case 75...100: dimension = 174 + CGFloat(weight - 75) / 25 * 26
        default: dimension = 200
        }
        return CGSize(width: dimension, height: dimension)
    }
}

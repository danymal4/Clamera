//
//  Fish.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import Foundation

class Fish: Identifiable, ObservableObject, Hashable {
    let id = UUID()
    var photo: String
    let speciesName: String
    @Published var description: String
    @Published var dateCaught: Date
    @Published var isPinned: Bool
    @Published var isAquarium: Bool
    @Published var isDeleted: Bool
    @Published var fishWeight: Int?
    
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
        if (self.fishWeight ?? -1 <= 0) {
            self.fishWeight = nil
        }
    }
    
    init(dictionary: [String: String]) {
        self.photo = dictionary["photo"] ?? ""
        self.speciesName = dictionary["speciesName"] ?? ""
        self.description = dictionary["description"] ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.dateCaught = dateFormatter.date(from: dictionary["date"] ?? "") ?? Date()
        self.isPinned = Bool(dictionary["isPinned"] ?? "false") ?? false
        self.isDeleted = Bool(dictionary["isDeleted"] ?? "false") ?? false
        self.fishWeight = Int(dictionary["fishWeight"] ?? "-1")
        self.isAquarium = false
        if (fishWeight ?? -1 >= 0) {
            fishWeight = nil
        }
    }
    
    func getDictionary() -> [String : String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dict: [String : String] =
        ["photo":self.photo,
         "speciesName":self.speciesName,
         "description":self.description,
         "dateCaught":dateFormatter.string(from: self.dateCaught),
         "isPinned":String(isPinned),
         "isDeleted":String(isDeleted),
         "fishWeight":String(fishWeight ?? -1)
        ]
        return dict
    }
    
    // Hashable conformance
    static func == (lhs: Fish, rhs: Fish) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    func getSize() -> CGSize {
        guard let weight = fishWeight else { return CGSize(width: 110, height: 110) } // default size

        let dimension: CGFloat

        switch weight {
        case 0...5:
            dimension = 20 + CGFloat(weight) / 5 * 22     // 20–42
        case 5...10:
            dimension = 42 + CGFloat(weight - 5) / 5 * 22 // 42–64
        case 10...20:
            dimension = 64 + CGFloat(weight - 10) / 10 * 22 // 64–86
        case 20...30:
            dimension = 86 + CGFloat(weight - 20) / 10 * 22 // 86–108
        case 30...40:
            dimension = 108 + CGFloat(weight - 30) / 10 * 22 // 108–130
        case 40...50:
            dimension = 130 + CGFloat(weight - 40) / 10 * 22 // 130–152
        case 50...75:
            dimension = 152 + CGFloat(weight - 50) / 25 * 22 // 152–174
        case 75...100:
            dimension = 174 + CGFloat(weight - 75) / 25 * 26 // 174–200
        default:
            dimension = 200 // anything above 100 lbs
        }

        return CGSize(width: dimension, height: dimension)
    }
}

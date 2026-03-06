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
         isPinned: Bool = true,
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

    // Hashable conformance
    static func == (lhs: Fish, rhs: Fish) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

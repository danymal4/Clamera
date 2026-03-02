//
//  Species.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

struct Species: Identifiable, Hashable {
    let id: String   // stable ID = species name
    let name: String
    let imageName: String
    let icon: String
    var fishList: [Fish]

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
}

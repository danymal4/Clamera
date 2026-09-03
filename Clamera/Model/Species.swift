//
//  Species.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

class Species: ObservableObject, Identifiable, Hashable {

    let id: String   // stable ID = species name
    let name: String
    let imageName: String
    let icon: String

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
    
    init(array: [[String:String]]) {
        var fishArr = array
        let specialDict = fishArr.removeLast()
        self.id = specialDict["name"] ?? ""
        self.name = specialDict["name"] ?? ""
        self.imageName = specialDict["imageName"] ?? ""
        self.icon = specialDict["icon"] ?? ""
        self.fishList = []
        update(fishArray: fishArr)
    }
    
    func update(fishArray: [[String:String]]) {
        var list: [Fish] = []
        for fishDict in fishArray {
            if !fishDict.isEmpty {
                list.append(Fish(dictionary: fishDict))
            }
        }
        self.fishList = list
    }

    func getArray() -> [[String:String]] {
        var fishArr: [[String:String]] = []
        for fish in fishList {
            fishArr.append(fish.getDictionary())
        }
        return fishArr
    }
    
    func getFullArray() -> [[String:String]] {
        var fishArr: [[String:String]] = self.getArray()
        let specialDict: [String:String] = [
            "name": name,
            "imageName": imageName,
            "icon": icon
        ]
        fishArr.append(specialDict)
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

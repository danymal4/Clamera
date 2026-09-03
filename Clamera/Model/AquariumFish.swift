//
//  AquariumFish.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

final class AquariumFish: Identifiable, ObservableObject {
    let id = UUID()
    @Published var imageName: String
    @Published var size: CGSize
    let horizontalRange: ClosedRange<CGFloat>
    let verticalRange: ClosedRange<CGFloat>
    @Published var swimDuration: Double
    let phaseOffset: Double
    @Published var isActive: Bool
    @Published var isShown: Bool
    
    // Track which species this fish belongs to (String now)
    var speciesID: String?

    init(
        imageName: String,
        size: CGSize,
        horizontalRange: ClosedRange<CGFloat>,
        verticalRange: ClosedRange<CGFloat>,
        swimDuration: Double,
        phaseOffset: Double,
        isActive: Bool,
        isShown: Bool
    ) {
        self.imageName = imageName
        self.size = size
        self.horizontalRange = horizontalRange
        self.verticalRange = verticalRange
        self.swimDuration = swimDuration
        self.phaseOffset = phaseOffset
        self.isActive = isActive
        self.isShown = isShown
        self.speciesID = nil
    }
    
    init(dict: [String:String]){
        self.imageName = dict["imageName"] ?? ""
        self.size = NSCoder.cgSize(for: dict["size"] ?? "")
        self.horizontalRange = AquariumFish.stringToClosedRange(string : dict["horizontalRange"] ?? "")
        self.verticalRange = AquariumFish.stringToClosedRange(string : dict["verticalRange"] ?? "")
        self.swimDuration = Double(dict["swimDuration"] ?? "1.1") ?? 1.1
        self.phaseOffset = Double(dict["phaseOffset"] ?? "0.0") ?? 0.0
        self.isActive = Bool(dict["isActive"] ?? "false") ?? false
        self.isShown = Bool(dict["isShown"] ?? "false") ?? false
        self.speciesID = dict["speciesID"]
    }
    
    func update(from dict: [String:String]) {
        self.imageName = dict["imageName"] ?? self.imageName
        let newSize = NSCoder.cgSize(for: dict["size"] ?? "")
        if newSize.width > 0 && newSize.height > 0 {
            self.size = newSize
        }
        if let dur = Double(dict["swimDuration"] ?? "") {
            self.swimDuration = dur
        }
        if let act = Bool(dict["isActive"] ?? "") {
            self.isActive = act
        }
        if let shw = Bool(dict["isShown"] ?? "") {
            self.isShown = shw
        }
        if let sID = dict["speciesID"] {
            self.speciesID = sID
        }
    }
    
    func getDictionary() -> [String:String]{
        var dict: [String:String] = [
            "imageName": imageName,
            "size": NSCoder.string(for: size),
            "horizontalRange": "\(horizontalRange.lowerBound)...\(horizontalRange.upperBound)",
            "verticalRange": "\(verticalRange.lowerBound)...\(verticalRange.upperBound)",
            "swimDuration": String(swimDuration),
            "phaseOffset": String(phaseOffset),
            "isActive": String(isActive),
            "isShown": String(isShown)
        ]
        if let id = speciesID {
            dict["speciesID"] = id
        }
        return dict
    }
    
    static func stringToClosedRange(string: String) -> ClosedRange<CGFloat> {
        var range: ClosedRange<CGFloat> = 0...1
        let comps = string.components(separatedBy: "...")
        if comps.count == 2 {
            let comp1 = CGFloat(Double(comps[0]) ?? 0)
            let comp2 = CGFloat(Double(comps[1]) ?? 1)
            range = comp1...comp2
        }
        return range
    }
}

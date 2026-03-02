//
//  Fish.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import Foundation

struct Fish: Identifiable, Hashable {
    let id = UUID()
    var photo: String
    let speciesName: String
    var description: String = "cool fish I found with sam"
    var dateCaught: Date = Date()
    var isPinned: Bool = true
    var isAquarium: Bool = false
    var fishWeight: Int?
}

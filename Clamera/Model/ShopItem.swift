//
//  ShopItem.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/31/26.
//

import Foundation

enum ShopCategory: String, Codable, CaseIterable {
    case all = "All"
    case fish = "Fish"
    case special = "Special"
}

struct ShopItem: Identifiable, Codable {
    let id: String
    let name: String
    let iconName: String
    let baseCost: Int
    let category: ShopCategory
}

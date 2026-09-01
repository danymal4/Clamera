//
//  Friend.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 8/31/26.
//

import Foundation

struct Friend: Identifiable, Codable {
    let id: String
    var name: String
    var username: String
    var imageName: String
    var isOnline: Bool
}

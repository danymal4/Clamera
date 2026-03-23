//
//  LeaderboardData.swift
//  Clamera
//
//  Created by Ellis Kamplain (student Lower Merion High School) on 3/23/26.
//

import SwiftUI

class LeaderboardData: ObservableObject {
    @Published var users: [LeaderboardUser] = [
        LeaderboardUser(name: "FishMaster69", points: 18000),
        LeaderboardUser(name: "FishNChips10", points: 13000),
        LeaderboardUser(name: "NotUrBaitBro", points: 8000),
        LeaderboardUser(name: "FindingNemo", points: 7500),
        LeaderboardUser(name: "RealFishHunter", points: 7200),
        LeaderboardUser(name: "SeaWeedKing", points: 6900),
        LeaderboardUser(name: "OceanMan", points: 6500),
        LeaderboardUser(name: "SharkBait", points: 6200),
        LeaderboardUser(name: "BubbleBeam", points: 5800),
        LeaderboardUser(name: "AquaMarine", points: 5500),
        LeaderboardUser(name: "DeepDiver", points: 5100),
        LeaderboardUser(name: "CoralReef", points: 4900),
        LeaderboardUser(name: "StarFishy", points: 4600),
        LeaderboardUser(name: "JellyJam", points: 4300),
        LeaderboardUser(name: "CrabbyPatty", points: 4000),
        LeaderboardUser(name: "LobsterMobster", points: 3800),
        LeaderboardUser(name: "ShrimpFried", points: 3500),
        LeaderboardUser(name: "WhaleHello", points: 3200),
        LeaderboardUser(name: "DolphinDive", points: 3000)
    ]

    
     func addUser(_ user: LeaderboardUser) {
         users.append(user)
         users.sort { $0.points > $1.points } // always sort descending
     }
    
}

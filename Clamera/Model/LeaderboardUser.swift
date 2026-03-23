//
//  LeaderboardUser.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/4/26.
//

import Foundation


class LeaderboardUser: Identifiable, Comparable {
    var id = UUID()
    var name: String
   @Published var points: Int
    
    init(name: String = "NoName", points: Int = 0){
        self.name = name
        self.points = points
    }
    
   
    static func < (lhs: LeaderboardUser, rhs: LeaderboardUser) -> Bool {
        return lhs.points > rhs.points
    }
    
    static func == (lhs: LeaderboardUser, rhs: LeaderboardUser) -> Bool {
        return lhs.points == rhs.points && lhs.name == rhs.name
    }
    
 
    func getRank(from leaderboard: [LeaderboardUser]) -> Int? {
      
        let sorted = leaderboard.sorted()
        
 
        if let index = sorted.firstIndex(where: { $0.id == self.id }) {
            return index + 1 // ranks start at 1
        }
        
        return nil 
    }
}

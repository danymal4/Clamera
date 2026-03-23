//
//  ClameraApp.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

@main
struct ClameraApp: App {
    
    @StateObject var user = User()
    @StateObject var leaderboard = LeaderboardData()
    
    var body: some Scene {
        WindowGroup {
            
              
                HomerView()   // ← just reference it
                    .environmentObject(user)
                    .environmentObject(leaderboard)
        }
    }
}

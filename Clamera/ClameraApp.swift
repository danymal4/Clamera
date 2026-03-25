//
//  ClameraApp.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI
import Firebase

@main
struct ClameraApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var user = User()
    @StateObject var leaderboard = LeaderboardData()

    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
                HomerView()
                    .environmentObject(user)
                    .environmentObject(leaderboard)
        }
    }
}

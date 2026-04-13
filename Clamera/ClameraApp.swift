//
//  ClameraApp.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

@main
struct ClameraApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var leaderboard = LeaderboardData()

    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if let user = auth.user {
                HomerView()
                    .environmentObject(user)
                    .environmentObject(leaderboard)
            } else {
                SignUpView()
            }
            
        }
    }
}

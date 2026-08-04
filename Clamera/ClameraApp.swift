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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct ClameraApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var leaderboard = LeaderboardData()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ClameraSplashView {
                if auth.isLoading {
                    // Holds the screen steady with a matching background while Firebase checks keychain
                    Color.cyan
                        .ignoresSafeArea()
                } else if let user = auth.user {
                    // If logged in, drops the curtain straight to HomerView
                    HomerView()
                        .environmentObject(user)
                        .environmentObject(leaderboard)
                } else {
                    // Otherwise, drops the curtain to the sign-up/sign-in flow
                    SignUpView()
                }
            }
        }
    }
}

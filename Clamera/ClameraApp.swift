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
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure global audio playback session so sounds play reliably across views and friends' aquariums
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ClameraSplashView {
                Group {
                    if auth.isLoading {
                        // Holds the screen steady with a matching background while Firebase checks keychain
                        Color.cyan
                            .ignoresSafeArea()
                    } else if let user = auth.user {
                        // If logged in, drops the curtain straight to HomerView
                        HomerView()
                            .environmentObject(user)
                    } else {
                        // Otherwise, drops the curtain to the sign-in flow
                        SignInView()
                    }
                }
                .environmentObject(auth)
                .sheet(item: $auth.pendingGoogleUser) { _ in
                    GoogleUsernameSetupView()
                        .environmentObject(auth)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    handleAppActive()
                }
            }
            // Forces the entire app to always render in light mode,
            // regardless of the device's system Dark Mode setting. This is
            // a direct SwiftUI API applied at the root of the view
            // hierarchy — more reliable than the Info.plist
            // UIUserInterfaceStyle key, which wasn't taking effect.
            .preferredColorScheme(.light)
        }
    }

    private func handleAppActive() {
        guard let currentUser = auth.user, !currentUser.id.isEmpty else { return }

        Task {
            let streakChanged = await MainActor.run {
                currentUser.checkLoginStreak()
            }
            if streakChanged {
                await FirestoreManager.shared.saveUser(user: currentUser)
            }
        }
    }
}

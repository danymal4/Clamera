//
//  ContentView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView("Loading...")
            } else if authManager.user != nil {
                Text("Welcome to Clamera, \(authManager.user?.username ?? "User")!")
                    .font(.title)
                    .bold()
            } else {
                SignInView()
            }
        }
        .sheet(item: $authManager.pendingGoogleUser) { _ in
            GoogleUsernameSetupView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}

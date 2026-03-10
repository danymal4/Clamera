//
//  HomerView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/4/26.

import SwiftUI

enum ViewState {
    case home, aquarium, profile, caught, album, social,  settings
}


final class TabRouter: ObservableObject {
    @Published var viewState: ViewState = .home
}


import SwiftUI

struct HomerView: View {
    @EnvironmentObject var user: User

    @StateObject private var tabRouter = TabRouter()
    @State private var cleanTimer: Timer?
    @State private var lastUpdate: Date = Date()



    var body: some View {
        TabView(selection: $tabRouter.viewState) {

            NavigationStack { HomeRevised() }
                .tag(ViewState.home)
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { CatchView() }
                .tag(ViewState.caught)
                .tabItem { Label("Catch", systemImage: "fish") }

            NavigationStack { AlbumView() }
                .tag(ViewState.album)
                .tabItem { Label("Album", systemImage: "book") }

            NavigationStack {
                AquariumView()
                    .onAppear {
                        user.aquariumState.markActive("aquarium")
                        lastUpdate = Date()
                        user.aquariumState.commitPendingClean()
                      
                    }
                    .onDisappear {
                        user.aquariumState.markInactive("aquarium")
                    }
            }
            .tag(ViewState.aquarium)
            .tabItem {
                Image("aquariumIcon").renderingMode(.template)
                    .foregroundColor(tabRouter.viewState == .aquarium ? .blue : .gray)
                Text("Aquarium")
            }

            NavigationStack { SocialView() }
                .tag(ViewState.social)
                .tabItem { Label("Social", systemImage: "person.2.fill") }

        }
        .environmentObject(tabRouter)
        .environmentObject(user)
        .onAppear { startCleanTimer() }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
        }
        .onChange(of: tabRouter.viewState) { newState in
            // Commit pending clean when switching back to Aquarium
            if newState == .aquarium {
                lastUpdate = Date()
                user.aquariumState.commitPendingClean()
            }
        }
    }

    private func startCleanTimer() {
        cleanTimer?.invalidate()
        let totalDuration: TimeInterval = 60 * 60 // 1 hour to go from dirty -> clean
         let tickInterval: TimeInterval = 5
        lastUpdate = Date()

        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(self.lastUpdate)
            self.lastUpdate = now

            // Only increment live clean if any active screen (Aquarium or Manage) is present
            if user.aquariumState.isActiveScreen {
                let increment = user.aquariumState.maxClean / totalDuration * delta
                user.aquariumState.updateClean(by: increment)
            } else {
                // Accumulate pending clean when no active screens
                let increment = user.aquariumState.maxClean / totalDuration * delta
                user.aquariumState.updatePendingClean(
                    to: min(user.aquariumState.pendingClean + increment, user.aquariumState.maxClean)
                )
            }
        }
    }
}

#Preview {
    HomerView()
        .environmentObject(User())
        .environmentObject(SpeciesStore())
}

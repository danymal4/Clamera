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
    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore
    @EnvironmentObject var aquariumState: AquariumState

    @StateObject private var tabRouter = TabRouter()
    @State private var cleanTimer: Timer?
    @State private var lastUpdate: Date = Date()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView(selection: $tabRouter.viewState) {

            NavigationStack { HomeView() }
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
                        aquariumState.markActive("aquarium")
                        lastUpdate = Date()
                        aquariumState.commitPendingClean()
                    }
                    .onDisappear {
                        aquariumState.markInactive("aquarium")
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
        .environmentObject(aquarium)
        .environmentObject(aquariumState)
        .environmentObject(speciesStore)
        .onAppear { startCleanTimer() }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
        }
        .onChange(of: tabRouter.viewState) { newState in
            // Commit pending clean when switching back to Aquarium
            if newState == .aquarium {
                lastUpdate = Date()
                aquariumState.commitPendingClean()
            }
        }
    }

    private func startCleanTimer() {
        cleanTimer?.invalidate()
        let totalDuration: TimeInterval = 60.0 * 5
        let tickInterval: TimeInterval = 0.5
        lastUpdate = Date()

        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(self.lastUpdate)
            self.lastUpdate = now

            // Only increment live clean if any active screen (Aquarium or Manage) is present
            if aquariumState.isActiveScreen {
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updateClean(by: increment)
            } else {
                // Accumulate pending clean when no active screens
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updatePendingClean(
                    to: min(aquariumState.pendingClean + increment, aquariumState.maxClean)
                )
            }
        }
    }
}

#Preview {
    HomerView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
        .environmentObject(AquariumState())
}

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

struct HomerView: View {
    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore
    @EnvironmentObject var aquariumState: AquariumState

    @StateObject private var tabRouter = TabRouter()
    @State private var cleanTimer: Timer?
    @State private var lastUpdate: Date = Date()

    // Controls the delayed aquarium animation
    @State private var showAquariumBottomBar: Bool = false
    @State private var tabsVisible: Bool = true

    // Timer for resetting the bottom bar
    @State private var bottomBarWorkItem: DispatchWorkItem?

    var body: some View {
        ZStack(alignment: .bottom) {
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
                    AquariumView(
                        showBottomBar: $showAquariumBottomBar,
                        resetBottomBarTimer: resetBottomBarTimer
                    )
                    .onAppear {
                        aquariumState.markActive("aquarium")
                        lastUpdate = Date()
                        aquariumState.commitPendingClean()

                        resetBottomBarTimer()
                    }
                    .onDisappear {
                        aquariumState.markInactive("aquarium")
                        showAquariumBottomBar = false
                        bottomBarWorkItem?.cancel()
                    }
                }
                .toolbar(showAquariumBottomBar ? .hidden : .visible, for: .tabBar)
                .tag(ViewState.aquarium)
                .tabItem {
                    Image("aquariumIcon")
                        .renderingMode(.template)
                        .foregroundColor(tabRouter.viewState == .aquarium ? .blue : .gray)
                    Text("Aquarium")
                }

                NavigationStack { SocialView() }
                    .tag(ViewState.social)
                    .tabItem { Label("Social", systemImage: "person.2.fill") }
            }
            .toolbar(tabRouter.viewState == .aquarium && showAquariumBottomBar ? .hidden : .visible, for: .tabBar)
            
        }
        .environmentObject(tabRouter)
        .environmentObject(aquarium)
        .environmentObject(aquariumState)
        .environmentObject(speciesStore)
        .onAppear { startCleanTimer() }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
            bottomBarWorkItem?.cancel()
        }
        .onChange(of: tabRouter.viewState) { newState in
            if newState == .aquarium {
                lastUpdate = Date()
                aquariumState.commitPendingClean()
            }
        }
    }

    private func startCleanTimer() {
        cleanTimer?.invalidate()
        let totalDuration: TimeInterval = 60 * 60
        let tickInterval: TimeInterval = 5
        lastUpdate = Date()

        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(self.lastUpdate)
            self.lastUpdate = now

            if aquariumState.isActiveScreen {
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updateClean(by: increment)
            } else {
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updatePendingClean(
                    to: min(aquariumState.pendingClean + increment, aquariumState.maxClean)
                )
            }
        }
    }

    // MARK: - Reset bottom bar timer
    func resetBottomBarTimer() {
        bottomBarWorkItem?.cancel()

        withAnimation(.easeOut(duration: 0.45)) {
            showAquariumBottomBar = false
        }

        let workItem = DispatchWorkItem {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showAquariumBottomBar = true
            }
        }

        bottomBarWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }
}

#Preview {
    HomerView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
        .environmentObject(AquariumState())
}

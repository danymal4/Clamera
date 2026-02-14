//
//  HomerView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/4/26.

import SwiftUI

enum ViewState {
    case home, aquarium, profile, caught, album
}

final class TabRouter: ObservableObject {
    @Published var viewState: ViewState = .home
}

struct HomerView: View {
    
    @StateObject private var tabRouter = TabRouter()
    @StateObject var aquariumState = AquariumState()
    @StateObject private var aquarium = AquariumFishList()
    @StateObject var speciesStore = SpeciesStore()

    
    // Global timer
    @State private var cleanTimer: Timer?
    
    // Track last timestamp for precise elapsed time
    @State private var lastUpdate: Date = Date()
    
    // Tab bar transparent appearance
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
            
            ZStack { Color.clear.ignoresSafeArea(); HomeView() }
                .tag(ViewState.home)
                .tabItem { Label("Home", systemImage: "house") }
            
            ZStack { CatchView() }
                .tag(ViewState.caught)
                .tabItem { Label("Catch", systemImage: "fish") }
            
            ZStack {
                AquariumView()
                    .onAppear {
                        // Commit pending clean immediately on appear
                        aquariumState.commitPendingClean()
                        
                        // Extra commit in next run loop to align first frame
                        DispatchQueue.main.async {
                            aquariumState.commitPendingClean()
                        }
                        
                        // Reset lastUpdate for timer
                        lastUpdate = Date()
                    }
            }
            .tag(ViewState.aquarium)
            .tabItem {
                Image("aquariumIcon")
                    .renderingMode(.template)
                    .foregroundColor(tabRouter.viewState == .aquarium ? .blue : .gray)
                Text("Aquarium")
            }
            
            ZStack { NavigationStack { AlbumView() } }
                .tag(ViewState.album)
                .tabItem { Label("Album", systemImage: "book") }
            
            ZStack { Color.clear.ignoresSafeArea(); ProfileView() }
                .tag(ViewState.profile)
                .tabItem { Label("Profile", systemImage: "person") }
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
        // Reset lastUpdate whenever switching to aquarium to prevent first-frame delta jumps
        .onChange(of: tabRouter.viewState) { newState in
            if newState == .aquarium {
                lastUpdate = Date()
                aquariumState.commitPendingClean()
            }
        }
    }
    
 


    private func startCleanTimer() {
        cleanTimer?.invalidate()
        
        let totalDuration: TimeInterval = 60.0 * 5    // 5 minutes
        let tickInterval: TimeInterval = 0.5          // slower tick for smoother rendering
        var lastUpdate = Date()
        
        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdate = now
            
            if tabRouter.viewState == .aquarium {
                // Increment scaled with delta — ensures smooth progress even with slower ticks
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.clean = min(aquariumState.clean + increment, aquariumState.maxClean)
            } else {
                // Pending clean updated off-screen proportionally
                let increment = aquariumState.maxClean * 0.05 / 60 * delta / tickInterval
                aquariumState.updatePendingClean(to: min(aquariumState.pendingClean + increment, aquariumState.maxClean))
            }
        }
    }



}

#Preview {
    HomerView()
        .environmentObject(TabRouter())
        .environmentObject(AquariumFishList())
        .environmentObject(AquariumState()).environmentObject(SpeciesStore())
}

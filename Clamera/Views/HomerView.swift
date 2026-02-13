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
        .onAppear { startCleanTimer() }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
        }
    }
    
    /// Optimized global timer
    /// Starts a single global timer for clean/pending updates with a 1-minute auto-reset
    private func startCleanTimer() {
        cleanTimer?.invalidate()
        
        let totalDuration: TimeInterval = 60.0
        let tickInterval: TimeInterval = 0.05
        var lastUpdate = Date()
        
        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdate = now
            
            if tabRouter.viewState == .aquarium {
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.clean = min(aquariumState.clean + increment, aquariumState.maxClean)
            } else {
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
        .environmentObject(AquariumState())
}

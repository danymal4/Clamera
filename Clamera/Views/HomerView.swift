//
//  HomerView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/4/26.

import SwiftUI

enum ViewState {
    case home, aquarium, profile, caught, album, social
}

final class TabRouter: ObservableObject {
    @Published var viewState: ViewState = .home
}

struct HomerView: View {

    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore
    @EnvironmentObject var aquariumState: AquariumState
    @StateObject private var tabRouter = TabRouter()

    //global timer
    @State private var cleanTimer: Timer?
    
  
    @State private var lastUpdate: Date = Date()

    // transparent tab bar looked up
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


            NavigationStack {
                HomeView()
            }
            .tag(ViewState.home)
            .tabItem { Label("Home", systemImage: "house") }

 
            NavigationStack {
                CatchView()
            }
            .tag(ViewState.caught)
            .tabItem { Label("Catch", systemImage: "fish") }
            
            
 
            NavigationStack {
                AlbumView()
            }
            .tag(ViewState.album)
            .tabItem { Label("Album", systemImage: "book") }

    
            NavigationStack {
                AquariumView()
                    .onAppear {
                        aquariumState.commitPendingClean()
                        DispatchQueue.main.async {
                            aquariumState.commitPendingClean()
                        }
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

          
            NavigationStack{
                SocialView()
            }
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
            if newState == .aquarium {
                lastUpdate = Date()
                aquariumState.commitPendingClean()
            }
        }
    }
    
    // global timer controlling filter: holds a pending value of clean while off aquariumView. Resets with animaton

    private func startCleanTimer() {
        cleanTimer?.invalidate()
        let totalDuration: TimeInterval = 60.0 * 5
        let tickInterval: TimeInterval = 0.5
        var lastUpdate = Date()

        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdate = now

            if tabRouter.viewState == .aquarium {
       
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updateClean(by: increment)
            } else {
                let increment = aquariumState.maxClean * 0.05 / 60 * delta / tickInterval
                aquariumState.updatePendingClean(to: min(aquariumState.pendingClean + increment, aquariumState.maxClean))
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

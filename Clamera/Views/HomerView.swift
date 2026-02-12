//
//  HomerView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/4/26.
//
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
    
    // tab bar transparent thing
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
            
            ZStack {
                Color.clear.ignoresSafeArea()
                HomeView()
            }
            .tag(ViewState.home)
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            ZStack {
                CatchView()
            }
            .tag(ViewState.caught)
            .tabItem {
                Label("Catch", systemImage: "fish")
            }
            
            ZStack {
                AquariumView()
            }
            .tag(ViewState.aquarium)
            .tabItem {
                Image("aquariumIcon")
                    .renderingMode(.template)
                    .foregroundColor(tabRouter.viewState == .aquarium ? .blue : .gray)
                Text("Aquarium")
            }
            
            ZStack {
                NavigationStack {
                    AlbumView()
                }
            }
            .tag(ViewState.album)
            .tabItem {
                Label("Album", systemImage: "book")
            }
            
            
       
            
            ZStack {
                Color.clear.ignoresSafeArea()
                ProfileView()
            }
            .tag(ViewState.profile)
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        
        .environmentObject(tabRouter)
        .environmentObject(aquarium) .environmentObject(aquariumState)
    }
}

#Preview {
    HomerView()
        .environmentObject(TabRouter())
        .environmentObject(AquariumFishList())
        .environmentObject(AquariumState())
}

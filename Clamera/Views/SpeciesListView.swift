//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
import SwiftUI

struct FishCardView: View {
    let imageName: String
    let animate: Bool
    
    @State private var isBreathing = false
    @State private var refreshID = UUID()
    
    private let baseWidth = UIScreen.main.bounds.width * 0.88
    private let baseHeight = UIScreen.main.bounds.width * 0.83
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.3))
                .frame(width: baseWidth, height: baseHeight)
            
            Image(fishPhoto: imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width * 0.85,
                    height: UIScreen.main.bounds.width * 0.8
                )
                .cornerRadius(10)
                .clipped()
                .scaleEffect(isBreathing ? 1.035 : 1.0)
            
            Image("anchorFrame")
                .resizable()
                .frame(
                    width: UIScreen.main.bounds.width * 1,
                    height: UIScreen.main.bounds.width * 0.95
                )
                .opacity(animate ? 0.8 : 0.0)
                .scaleEffect(isBreathing ? 1.035 : 1.0)
                .allowsHitTesting(false)
        }
        .id(refreshID) // forces refresh when changed
        .frame(width: baseWidth, height: baseHeight)
        .onAppear {
            restartAnimation()
        }
        .onChange(of: animate) { _ in
            restartAnimation()
        }
        .onDisappear {
            isBreathing = false
        }
    }
    
    private func restartAnimation() {
        guard animate else {
            isBreathing = false
            return
        }
        
        refreshID = UUID() // forces clean rebuild
        isBreathing = false
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }
}

extension Image {
    /// Loads an image either from the app bundle (assets) or the documents folder
    init(fishPhoto name: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
        
        if let uiImage = UIImage(contentsOfFile: url.path) {
            self.init(uiImage: uiImage)
        } else {
            self.init(name) // fallback to asset catalog image
        }
    }
}

struct SpeciesListView: View {

    @ObservedObject var aquarium: AquariumFishList
    @ObservedObject var speciesStore: SpeciesStore
    let speciesIndex: Int

    enum FilterOption: String, CaseIterable, Identifiable {
        case oldest = "Oldest"
        case newest = "Newest"
 
        var id: String { self.rawValue }
    }

    @State private var selectedFilter: FilterOption = .oldest
    @State private var showPinnedOnly: Bool = false


    var species: Species {
        speciesStore.speciesList[speciesIndex]
    }

    // Filtered fish list driving UI
    var filteredFish: [Fish] {
        var fish = species.fishList
        
        // Apply sort first
        if selectedFilter == .newest {
            fish.reverse()
        }
        
        // Then apply pinned filter if active
        if showPinnedOnly {
            fish = fish.filter { !$0.isPinned }
        }
        
        return fish
    }

    var body: some View {
        ZStack {
            ScrollView {
                ZStack(alignment: .top) {
               
                    Color.clear.frame(height: UIScreen.main.bounds.height)
                    
                    WaterView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(y: -310)

                    IconView().offset(y: -40)
                    
                    
                    
                    
                    // Filter Menu at top-right
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button(selectedFilter == .oldest ? "Oldest  ✓" : "Oldest") {
                                selectedFilter = .oldest
                            }
                            
                            Button(selectedFilter == .newest ? "Newest  ✓" : "Newest") {
                                selectedFilter = .newest
                            }
                            
                            Button(showPinnedOnly ? "Pinned  ✓" : "Pinned") {
                                showPinnedOnly.toggle()
                            }
                        } label: {
                            VStack {
                                Image(systemName: "line.horizontal.3.decrease")
                                    .foregroundStyle(.black)
                                Text("Filter")
                                    .font(.custom("HelveticaNeue-Thin", size: 15))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 75)
                        
                    }
                    VStack(spacing: 20) {
                        Text(species.name)
                            .font(.custom("IslandMoments-Regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top)

                        // Fish list
                        ForEach(filteredFish) { fish in
                            if let fishBinding = binding(for: fish) {
                                fishRowView(fish: fish, fishBinding: fishBinding)
                            }
                        }
                    }
                }
            }

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.bottom, -300)
            }
        }
    }

    // MARK: - Helper functions

    /// Compute binding for a fish
    private func binding(for fish: Fish) -> Binding<Fish>? {
        guard let speciesIdx = speciesStore.speciesList.firstIndex(where: { $0.id == species.id }),
              let fishIdx = speciesStore.speciesList[speciesIdx]
                .fishList.firstIndex(where: { $0.id == fish.id }) else {
            return nil
        }
        return $speciesStore.speciesList[speciesIdx].fishList[fishIdx]
    }

    /// A separate small view for each fish row
    @ViewBuilder

    private func fishRowView(fish: Fish, fishBinding: Binding<Fish>) -> some View {
        VStack {
            NavigationLink(
                destination: FishDetailsView(speciesStore: speciesStore, aquarium: aquarium, fishID: fish.id)
            ) {
                FishCardView(imageName: fish.photo, animate: !fish.isPinned)
                    .id(fish.isPinned)
            }

            Text("5/30")
                .bold()
                .font(.system(size: UIScreen.main.bounds.width * 0.05))
                .opacity(0.7)
                .scaleEffect(!fish.isPinned ? 1.035 : 1.0)
                .animation(
                    !fish.isPinned
                    ? .easeInOut(duration: 4).repeatForever(autoreverses: true)
                    : .default,
                    value: !fish.isPinned
                )
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }

}

#Preview {
    let store = SpeciesStore()
    let aquarium = AquariumFishList()
    
    NavigationStack {
        SpeciesListView(aquarium: aquarium, speciesStore: store, speciesIndex: 0)
    }
}

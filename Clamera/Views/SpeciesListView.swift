//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

struct FishCardView: View {
    let imageName: String
    let animate: Bool // true for unpinned, false for pinned
    
    var body: some View {
        ZStack {
            
            // Base rectangle
            RoundedRectangle(cornerRadius: 15)
                .frame(
                    width: UIScreen.main.bounds.width * 0.88,
                    height: UIScreen.main.bounds.width * 0.83
                )
                .foregroundStyle(Color.white.opacity(0.3))
                .scaleEffect(animate ? 1.035 : 1.0)
            
            if animate {
                RoundedRectangle(cornerRadius: 15)
                    .frame(
                        width: UIScreen.main.bounds.width * 0.88,
                        height: UIScreen.main.bounds.width * 0.83
                    )
                    .foregroundStyle(Color.mint)
                    .opacity(animate ? 0.5 : 0.0)
                    .scaleEffect(animate ? 1.035 : 1.0)
            }
            
            // Fish image
            Image(fishPhoto: imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width * 0.85,
                    height: UIScreen.main.bounds.width * 0.8
                )
                .cornerRadius(10)
                .clipped()
                .scaleEffect(animate ? 1.035 : 1.0)
        }
        .animation(
            animate
            ? .easeInOut(duration: 2.2).repeatForever(autoreverses: true)
            : .default,
            value: animate
        )
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
    @State private var filterCheckArray = [true, false] // [Oldest, Newest]

    var species: Species {
        speciesStore.speciesList[speciesIndex]
    }

    // Filtered fish list driving UI
    var filteredFish: [Fish] {
        var fish = species.fishList
        if selectedFilter == .newest {
            fish.reverse()
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
                            Button(filterCheckArray[0] ? "Oldest  *" : "Oldest") {
                                selectedFilter = .oldest
                                for i in filterCheckArray.indices { filterCheckArray[i] = false }
                                filterCheckArray[0] = true
                            }
                            Button(filterCheckArray[1] ? "Newest  *" : "Newest") {
                                selectedFilter = .newest
                                for i in filterCheckArray.indices { filterCheckArray[i] = false }
                                filterCheckArray[1] = true
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
                    }
                    .padding(.horizontal)
                    .padding(.top, 75)

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
            }

            Text("5/30")
                .bold()
                .font(.system(size: UIScreen.main.bounds.width * 0.05))
                .opacity(0.7)
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

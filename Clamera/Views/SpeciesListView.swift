//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI


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
    @State private var showPinnedOnly: Bool = true

    var species: Species {
        speciesStore.speciesList[speciesIndex]
    }

    // filter mechanic
    var filteredFish: [Fish] {
        var fish = species.fishList
        
        if selectedFilter == .newest {
            fish.reverse()
        }
        
        if showPinnedOnly {
            fish = fish.filter { $0.isPinned }
        }
        
        return fish
    }

    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack {
            ScrollView {
                ZStack(alignment: .top) {
                    Color.clear.frame(height: UIScreen.main.bounds.height)
                    WaterView().opacity(0.3)
                    IconView().offset(y: -40)

                    VStack(spacing: 20) {
                        Text(species.name)
                            .font(.custom("AkayaTelivigala-regular", size: 70))
                            .foregroundStyle(.blue).opacity(0.8)
                            .padding(.top)

                        // Filter buttons
                        HStack {
                            filterButton(title: "Oldest", selected: selectedFilter == .oldest) { selectedFilter = .oldest }
                            filterButton(title: "Newest", selected: selectedFilter == .newest) { selectedFilter = .newest }
                            filterButton(title: "Pinned", selected: !showPinnedOnly) { showPinnedOnly.toggle() }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .colorInvert()
                                .frame(width: UIScreen.main.bounds.width * 0.85,
                                       height: UIScreen.main.bounds.width * 0.13)
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        )

                        // Grid of fish
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(filteredFish) { fish in
                                if let fishBinding = binding(for: fish) {
                                    NavigationLink(
                                        destination: FishDetailsView(speciesStore: speciesStore, aquarium: aquarium, fishID: fish.id)
                                    ) {
                                        FishGridItem(fish: fish, clickable: true)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 83)
                    .overlay(Color.blue.opacity(0.06))
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.bottom, -300)
            }
        }
        .background(Color.blue.opacity(0.08))
    }

    // MARK: - Binding Helper
    private func binding(for fish: Fish) -> Binding<Fish>? {
        guard let speciesIdx = speciesStore.speciesList.firstIndex(where: { $0.id == species.id }),
              let fishIdx = speciesStore.speciesList[speciesIdx]
                .fishList.firstIndex(where: { $0.id == fish.id }) else {
            return nil
        }
        return $speciesStore.speciesList[speciesIdx].fishList[fishIdx]
    }

    // MARK: - Filter Button
    @ViewBuilder
    private func filterButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                if selected {
                    SmallRoundedCard()
                } else {
                    SmallRoundedCard().opacity(0.0)
                }
                Text(title)
                    .foregroundStyle(Color.black)
                    .opacity(0.7)
            }
        }
    }
}

// MARK: - Fish Grid Item (like AlbumView)
struct FishGridItem: View {
    let fish: Fish
    let clickable: Bool
    
    private var cardWidth: CGFloat { UIScreen.main.bounds.width * 0.45 }
    private var cardHeight: CGFloat { cardWidth }

    var body: some View {
        ZStack {
            Image(fishPhoto: fish.photo)
                .resizable()
                .scaledToFill()
                .frame(
                    width: cardWidth * 0.95,
                    height: cardHeight * 0.95
                )
                .cornerRadius(25)
                .clipped()
                .opacity(clickable ? 1.0 : 0.4)
                .shadow(color: .black.opacity(0.1), radius: 20)
            
            
          
        }
    }
}

// MARK: - Image Loader Extension
extension Image {
    init(fishPhoto name: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
        
        if let uiImage = UIImage(contentsOfFile: url.path) {
            self.init(uiImage: uiImage)
        } else {
            self.init(name)
        }
    }
}


struct SmallRoundedCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(
                width: UIScreen.main.bounds.width * 0.265,
                height: UIScreen.main.bounds.width * 0.105
            )
            .foregroundStyle(Color.gray)
            .opacity(0.1)
    }
}





#Preview {
    let store = SpeciesStore()
    let aquarium = AquariumFishList()
    
    NavigationStack {
        SpeciesListView(aquarium: aquarium, speciesStore: store, speciesIndex: 0)
    }
}

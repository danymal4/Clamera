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
    @State private var showPinnedOnly: Bool = false
    @State private var refreshID = false

    var species: Species {
        speciesStore.speciesList[speciesIndex]
    }

    // filter mechanic
    var filteredFish: [Fish] {
        var fish = species.fishList

        // Sort by filter
        if selectedFilter == .newest {
            fish.reverse()
        }

        // Always show pinned fish; optionally hide unpinned fish if showPinnedOnly is true
        if showPinnedOnly {
            fish = fish.filter { !$0.isPinned }
        }
        
        return fish
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Aquarium Header
                    HStack(spacing: 16) {
                        Image("\(species.name)Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(species.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("\(species.fishList.count) Fish")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            if let heaviest = species.fishList.max(by: { ($0.fishWeight ?? 0) < ($1.fishWeight ?? 0) }) {
                                Text("Heaviest: \(heaviest.fishWeight ?? 0) lbs")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .lineLimit(1)

                        Spacer()

                        // Determine button states
                        let hasAvailableToAdd = species.fishList.contains { !$0.isAquarium } && !aquarium.checkAll()
                        let hasAvailableToRemove = species.fishList.contains { $0.isAquarium }

                        HStack(spacing: 12) {
                            // Add Fish Button
                            Button {
                                var activeNum = 0
                                if hasAvailableToAdd {
                                    for fish in species.fishList {
                                        guard activeNum < 3 else { break } // stop if we reached the limit
                                        if !fish.isAquarium {
                                            if let fishBinding = binding(for: fish) {
                                                aquarium.addFish(with: "\(species.name)Icon")
                                                fishBinding.isAquarium.wrappedValue.toggle()
                                                aquarium.refresh()
                                                activeNum = 3 // stop further additions
                                            }
                                        }
                                        activeNum += 1
                                    }
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(hasAvailableToAdd ? .blue : .gray).opacity(hasAvailableToAdd ? 1.0 : 0.6)
                            }

                            // Remove Fish Button
                            Button {
                                for fish in species.fishList {
                                    guard fish.isAquarium, let fishBinding = binding(for: fish) else { continue }

                                    aquarium.removeFish(with: "\(species.name)Icon")
                                    fishBinding.isAquarium.wrappedValue = false
                                }

                                // Refresh once after all removals
                                aquarium.refresh()

                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(hasAvailableToRemove ? .red : .gray).opacity(hasAvailableToRemove ? 1.0 : 0.6)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white).overlay(Color.blue.opacity(0.075).cornerRadius(25))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    // Catch Log Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Catch Log")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.black)
                        
                        ZStack {
                            Rectangle()
                                .colorInvert()
                                .cornerRadius(22)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                                .padding(.vertical, -4)
                                .padding(.horizontal, 13)

                            HStack {
                                filterButton(title: "Oldest", selected: selectedFilter == .oldest) {
                                    selectedFilter = .oldest
                                }
                                filterButton(title: "Newest", selected: selectedFilter == .newest) {
                                    selectedFilter = .newest
                                }
                                filterButton(title: "Pinned", selected: showPinnedOnly) {
                                    showPinnedOnly.toggle()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                    .padding(.vertical, 6)

                    // Fish Cards
                    VStack(spacing: 10) {
                        ForEach(filteredFish) { fish in
                            if let fishBinding = binding(for: fish) {
                                NavigationLink(
                                    destination: FishDetailsView(
                                        speciesStore: speciesStore,
                                        aquarium: aquarium,
                                        fishID: fish.id
                                    )
                                ) {
                                    FishGridItem(fish: fish, clickable: true) {
                                        fishBinding.isPinned.wrappedValue.toggle() // <-- WORKING ANCHOR
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 120)
                }
            }

       
        }
        .background(Color.blue.opacity(0.01))
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

// Updated FishGridItem with toggle closure
struct FishGridItem: View {
    var fish: Fish
    let clickable: Bool
    var onTogglePinned: (() -> Void)? // <- new callback

    private var cardWidth: CGFloat { UIScreen.main.bounds.width - 32 }
    private var cardHeight: CGFloat { cardWidth * 0.35 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .frame(width: cardWidth, height: cardWidth * 0.45)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )

            HStack(spacing: 20) {
                VStack {
                  
                    Image(fishPhoto: fish.photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardHeight, height: cardHeight)
                        .cornerRadius(16)
                        .clipped()
                        .opacity(clickable ? 1.0 : 0.4)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4).padding(.top, 11)
                       
                    Spacer()
                    
                }
            

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if let weight = fish.fishWeight {
                            Text("\(weight) lbs")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .bold()
                                .foregroundColor(.black.opacity(0.85))
                        }

                        Text(fish.dateCaught.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: UIScreen.main.bounds.width * 0.04))
                            .bold()
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .allowsTightening(true)

                        Spacer()

                        Button {
                            onTogglePinned?() // <- toggles pin in parent
                        } label: {
                            Image(fish.isPinned ? "anchorUnpinned" : "anchor")
                                .resizable()
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.08, 180),
                                    height: min(UIScreen.main.bounds.width * 0.1, 180)
                                )
                                .scaleEffect(fish.isPinned ? 1.0 : 0.95)
                                .opacity(fish.isPinned ? 1.0 : 0.8)
                        }
                        .padding(.top)
                    }

                    Text(fish.description)
                        .font(.system(size: UIScreen.main.bounds.width * 0.035))
                        .foregroundColor(.black.opacity(0.65))
                        .lineLimit(2)

                    Spacer()

                    HStack {
                        Spacer()
                        Button { } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red.opacity(0.85))
                        }
                        .padding(.bottom)
                    }
                }

            }
            .padding(.horizontal, 12)
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
    let aquarium = AquariumFishList()
    
    // SAMPLE FISH
    let fish1 = Fish(
        photo: "clownfish1",
        speciesName: "Largemouth Bass",
        description: "Caught near the dock at sunset.",
        dateCaught: Date(),
        isPinned: true,
        isAquarium: false,
        fishWeight: 4
    )
    
    let fish2 = Fish(
        photo: "clownfish2",
        speciesName: "Largemouth Bass",
        description: "Big one by the weeds.",
        dateCaught: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        isPinned: true,
        isAquarium: true,
        fishWeight: 6
    )
    
    let fish3 = Fish(
        photo: "clownfish3",
        speciesName: "Largemouth Bass",
        description: "Small but fought hard.",
        dateCaught: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        isPinned: true,
        isAquarium: false,
        fishWeight: 3
    )
    
    // SAMPLE SPECIES
    let sampleSpecies = Species(
        name: "Largemouth Bass",
        imageName: "largemouthBassPhoto",
        icon: "clownfishIcon",
        fishList: [fish1, fish2, fish3]
    )
    
    // Use preview initializer
    let store = SpeciesStore(previewSpecies: [sampleSpecies])
    
    NavigationStack {
        SpeciesListView(
            aquarium: aquarium,
            speciesStore: store,
            speciesIndex: 0
        )
    }
}

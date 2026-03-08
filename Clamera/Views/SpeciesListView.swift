//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI


struct SpeciesListView: View {

    @ObservedObject var aquarium: AquariumFishList
    @ObservedObject var species: Species
    @EnvironmentObject var speciesStore: SpeciesStore

    enum FilterOption: String, CaseIterable, Identifiable {
        case oldest = "Oldest"
        case newest = "Newest"
        var id: String { rawValue }
    }

    @State private var selectedFilter: FilterOption = .oldest
    @State private var showPinnedOnly: Bool = false

    // MARK: - Filter mechanic
    var filteredFish: [Fish] {
        species.fishList
            .filter { !showPinnedOnly || $0.isPinned }
            .sorted {
                selectedFilter == .oldest
                    ? $0.dateCaught < $1.dateCaught
                    : $0.dateCaught > $1.dateCaught
            }
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

                            Text("\(species.fishList.count) Fish")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            if let heaviest = species.fishList.max(by: {
                                ($0.fishWeight ?? 0) < ($1.fishWeight ?? 0)
                            }) {
                                Text("Heaviest: \(heaviest.fishWeight ?? 0) lbs")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        HStack(spacing: 12) {

                            // Computed inside body so it updates live
                            let hasAvailableToAdd = species.fishList.contains { !$0.isAquarium } && !aquarium.checkAll()
                            let hasAvailableToRemove = species.fishList.contains { $0.isAquarium }

                            // Add Fish
                            Button {
                                var activeNum = 0

                                for fish in species.fishList {
                                    guard activeNum < 3 else { break }

                                    if !fish.isAquarium {
                                        aquarium.addFish(
                                            with: "\(species.name)Icon",
                                            speciesID: species.id
                                        )
                                        fish.isAquarium = true
                                        activeNum = 3
                                        
                                    }

                                    activeNum += 1
                                }

                                aquarium.refresh()

                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(hasAvailableToAdd ? .blue : .gray)
                                    .opacity(hasAvailableToAdd ? 1 : 0.6)
                            }
                            .disabled(!hasAvailableToAdd)

                            // Remove Fish
                            Button {
                                if let fishToRemove = species.fishList.first(where: { $0.isAquarium }) {
                                    aquarium.removeFish(with: "\(species.name)Icon")
                                    fishToRemove.isAquarium = false
                                    aquarium.refresh()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(hasAvailableToRemove ? .red : .gray)
                                    .opacity(hasAvailableToRemove ? 1 : 0.6)
                            }
                            .disabled(!hasAvailableToRemove)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .overlay(Color.blue.opacity(0.075).cornerRadius(25))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    // Catch Log Header
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Catch Log")
                            .font(.system(size: 26, weight: .bold))

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
                            FishGridItem(
                                fish: fish,
                                species: species,
                                clickable: true
                            ) {
                                fish.isPinned.toggle()
                            }
                        }

                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 120)
                }
            }
        }.onAppear {
            speciesStore.refresh()
        }
        .background(Color.blue.opacity(0.01))
    }

    // MARK: - Filter Button
    @ViewBuilder
    private func filterButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {

        Button(action: action) {

            ZStack {

                if selected {
                    SmallRoundedCard()
                } else {
                    SmallRoundedCard().opacity(0)
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

    @ObservedObject var fish: Fish
    @ObservedObject var species: Species

    let clickable: Bool
    var onTogglePinned: (() -> Void)?

    private var cardWidth: CGFloat { UIScreen.main.bounds.width - 32 }
    private var cardHeight: CGFloat { cardWidth * 0.35 }

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .frame(width: cardWidth, height: cardWidth * 0.45)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
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
                        .opacity(clickable ? 1 : 0.4)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .padding(.top, 11)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {

                    HStack(spacing: 8) {

                        if let weight = fish.fishWeight {
                            let isHeaviest = fish == species.fishList.max(by: { ($0.fishWeight ?? 0) < ($1.fishWeight ?? 0) })

                            Text("\(weight) lbs")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .bold()
                                .foregroundColor(isHeaviest ? .yellow : .primary)
                                .shadow(color: isHeaviest ? .yellow.opacity(0.7) : .clear,
                                        radius: isHeaviest ? 6 : 0,
                                        x: 0, y: 0)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isHeaviest)
                        }

                        Text(fish.dateCaught.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: UIScreen.main.bounds.width * 0.04))
                            .bold()
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1)

                        Spacer()

                        Button {
                            onTogglePinned?()
                        } label: {

                            Image(fish.isPinned ? "anchor" : "anchorUnpinned")
                                .resizable()
                                .frame(
                                    width: UIScreen.main.bounds.width * 0.08,
                                    height: UIScreen.main.bounds.width * 0.1
                                )
                                .scaleEffect(fish.isPinned ? 1 : 0.95)
                                .opacity(fish.isPinned ? 1 : 0.8)
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
                        if species.fishList.count > 1 {
                            Button {
                                
                                species.fishList.removeAll { $0.id == fish.id }
                                
                            } label: {
                                
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red.opacity(0.85))
                            }
                            .padding(.bottom)
                        }
                        
                        else {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.gray.opacity(0.85))
                        
                        .padding(.bottom)
                        }
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
    let speciesStore = SpeciesStore()

    let fish1 = Fish(
        photo: "clownfish1",
        speciesName: "Largemouth Bass",
        description: "Caught near the dock at sunset.",
        dateCaught: Date(),
        isPinned: false,
        isAquarium: false,
        fishWeight: 4
    )

    let fish2 = Fish(
        photo: "clownfish2",
        speciesName: "Largemouth Bass",
        description: "Big one by the weeds.",
        dateCaught: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        isPinned: false,
        isAquarium: true,
        fishWeight: 6
    )

    let fish3 = Fish(
        photo: "clownfish3",
        speciesName: "Largemouth Bass",
        description: "Small but fought hard.",
        dateCaught: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        isPinned: false,
        isAquarium: false,
        fishWeight: 3
    )

    let sampleSpecies = Species(
        name: "Largemouth Bass",
        imageName: "largemouthBassPhoto",
        icon: "clownfishIcon",
        fishList: [fish1, fish2, fish3]
    )

    NavigationStack {
        SpeciesListView(
            aquarium: aquarium,
            species: sampleSpecies
        )
    }
    .environmentObject(speciesStore)
}

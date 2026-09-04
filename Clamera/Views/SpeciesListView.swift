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
    @EnvironmentObject var user: User
    
    var startWithPinnedOnly: Bool = false

    enum FilterOption: String, CaseIterable, Identifiable {
        case oldest = "Oldest"
        case newest = "Newest"
        var id: String { rawValue }
    }

    @State private var selectedFilter: FilterOption = .newest
    @State private var showPinnedOnly: Bool = false

    private var effectiveFishList: [Fish] {
        if !species.fishList.isEmpty {
            return species.fishList
        }
        
        let speciesClean = species.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        let isUnlockedInStore = user.unlockedShopItems.contains { itemId in
            let itemClean = itemId.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            return itemClean.contains(speciesClean) || speciesClean.contains(itemClean)
        }
        
        if isUnlockedInStore {
            return [
                Fish(
                    photo: "\(species.name)Icon",
                    speciesName: species.name,
                    description: "Unlocked from the shop!",
                    dateCaught: Date(),
                    isPinned: false,
                    isAquarium: false,
                    fishWeight: 1
                )
            ]
        }
        
        return []
    }
    
    var filteredFish: [Fish] {
        effectiveFishList
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

                    // Species Header with clear Add/Remove Aquarium labels
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
                                .font(.system(size: 20, weight: .bold)).lineLimit(2).minimumScaleFactor(0.7)

                            let totalCount = effectiveFishList.count
                            Text("\(totalCount) Fish")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            if let heaviest = effectiveFishList.max(by: {
                                ($0.fishWeight ?? 0) < ($1.fishWeight ?? 0)
                            }) {
                                Text("Heaviest: \(heaviest.fishWeight ?? 0) lbs")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }

                        }

                        Spacer()

                        HStack(spacing: 16) {
                            let hasAvailableToAdd = effectiveFishList.contains { !$0.isAquarium } && !aquarium.checkAll()
                            let hasAvailableToRemove = effectiveFishList.contains { $0.isAquarium } || aquarium.fish.contains { $0.isActive && $0.speciesID == species.id }

                            // Add fish to aquarium
                            VStack(spacing: 2) {
                                Button {
                                    // If this is a shop-unlocked species without fish in fishList, materialize it
                                    if species.fishList.isEmpty && !effectiveFishList.isEmpty {
                                        species.fishList.append(contentsOf: effectiveFishList)
                                    }

                                    if let newestAvailableFish = species.fishList
                                        .filter({ !$0.isAquarium })
                                        .max(by: { $0.dateCaught < $1.dateCaught }) {

                                        aquarium.addFish(
                                            with: "\(species.name)Icon",
                                            speciesID: species.id,
                                            size: newestAvailableFish.getSize()
                                        )

                                        newestAvailableFish.isAquarium = true
                                    }

                                    aquarium.refresh()
                                    Task {
                                        if let user = AuthManager.shared.user {
                                            await FirestoreManager.shared.saveUser(user: user)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(hasAvailableToAdd ? .cyan : .gray)
                                        .opacity(hasAvailableToAdd ? 1 : 0.5)
                                        .shadow(
                                            color: hasAvailableToAdd ? Color.cyan.opacity(0.3) : .clear,
                                            radius: 3,
                                            x: 0,
                                            y: 2
                                        )
                                }
                                .disabled(!hasAvailableToAdd)
                                
                                Text("Aquarium")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }

                            // Remove fish from aquarium
                            VStack(spacing: 2) {
                                Button {
                                    // Target fish that IS in the aquarium
                                    if let newestAquariumFish = species.fishList
                                        .filter({ $0.isAquarium })
                                        .max(by: { $0.dateCaught < $1.dateCaught }) {

                                        newestAquariumFish.isAquarium = false
                                        user.aquarium.removeFish(
                                            with: "\(species.name)Icon",
                                            targetSize: newestAquariumFish.getSize()
                                        )
                                    } else {
                                        // Fallback if added via shop without explicit fish list sync
                                        if let aquaFish = aquarium.fish.first(where: {
                                            $0.isActive && ($0.imageName == "\(species.name)Icon" || $0.speciesID == species.id)
                                        }) {
                                            user.aquarium.removeFish(
                                                with: "\(species.name)Icon",
                                                targetSize: aquaFish.size
                                            )
                                        }
                                    }

                                    aquarium.refresh()
                                    Task {
                                        if let user = AuthManager.shared.user {
                                            await FirestoreManager.shared.saveUser(user: user)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(hasAvailableToRemove ? Color(red: 0.0, green: 0.5, blue: 0.65) : .gray)
                                        .opacity(hasAvailableToRemove ? 1 : 0.5)
                                        .shadow(
                                            color: hasAvailableToRemove ? Color.cyan.opacity(0.3) : .clear,
                                            radius: 3,
                                            x: 0,
                                            y: 2
                                        )
                                }
                                .disabled(!hasAvailableToRemove)
                                
                                Text("Remove")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .overlay(Color.cyan.opacity(0.2).cornerRadius(25))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 10) {

                        Text("Catch Log")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 10) {
                            Picker("", selection: $selectedFilter) {
                                Text("Newest").tag(FilterOption.newest)
                                Text("Oldest").tag(FilterOption.oldest)
                            }
                            .pickerStyle(.segmented)

                            Button {
                                showPinnedOnly.toggle()
                                Task {
                                    if let user = AuthManager.shared.user {
                                        await FirestoreManager.shared.saveUser(user: user)
                                    }
                                }
                            } label: {
                                Image(systemName: showPinnedOnly ? "pin.fill" : "pin")
                                    .foregroundColor(showPinnedOnly ? .cyan : .secondary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(showPinnedOnly ? Color.cyan.opacity(0.15) : Color.gray.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                    .padding(.bottom, 6)

                    VStack(spacing: 10) {
                        ForEach(filteredFish) { fish in
                            FishGridItem(
                                fish: fish,
                                species: species,
                                clickable: true,
                                showPinnedOnly: $showPinnedOnly
                            ) {
                                fish.isPinned.toggle()
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            user.speciesStore.refresh()
            showPinnedOnly = startWithPinnedOnly
        }
        .background(Color.blue.opacity(0.01))
    }
}

// Grid item view with responsive aspect scaling
struct FishGridItem: View {

    @EnvironmentObject var speciesStore: SpeciesStore
    @ObservedObject var fish: Fish
    @ObservedObject var species: Species
    @EnvironmentObject var user: User
    @State private var showDeleteFishConfirm = false
    @Binding var showPinnedOnly: Bool

    let clickable: Bool
    var onTogglePinned: (() -> Void)?

    private var cardWidth: CGFloat { min(UIScreen.main.bounds.width - 32, 540) }
    private var cardHeight: CGFloat { cardWidth * 0.35 }
    
    private var isIconAsset: Bool {
        UIImage(named: fish.photo) != nil || fish.photo.hasSuffix("Icon")
    }

    init(fish: Fish,
         species: Species,
         clickable: Bool,
         showPinnedOnly: Binding<Bool>,
         onTogglePinned: (() -> Void)? = nil) {
          self.fish = fish
          self.species = species
          self.clickable = clickable
          self._showPinnedOnly = showPinnedOnly
          self.onTogglePinned = onTogglePinned
     }

    var body: some View {
        Group {
            if clickable {
                NavigationLink(destination: FishDetailsView(speciesStore: user.speciesStore, aquarium: user.aquarium, fishID: fish.id)) {
                    fishCardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                fishCardContent
            }
        }
    }

    private var fishCardContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: fish.isPinned
                            ? [
                                Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.28),
                                Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.12)
                              ]
                            : [Color.white, Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: cardWidth, height: cardWidth * 0.45)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 16,
                    y: 6
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            fish.isPinned
                                ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.2)
                                : Color.black.opacity(0.04),
                            lineWidth: 2
                        )
                )

            HStack(spacing: 20) {
                VStack {
                    ZStack {
                        Color.cyan.opacity(0.08)

                        if fish.photo.hasPrefix("http") {
                            AsyncImage(url: URL(string: fish.photo)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                        } else if isIconAsset {
                            Image(fishPhoto: fish.photo)
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                        } else {
                            Image(fishPhoto: fish.photo)
                                .resizable()
                                .scaledToFill()
                        }
                    }
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
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(isHeaviest ? .yellow : .primary)
                        }
                        
                        Text(fish.dateCaught.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1)

                        Spacer()

                        Button {
                            onTogglePinned?()
                            user.speciesStore.assignPinnedDisplay()
                            
                            if showPinnedOnly {
                                user.aquarium.refresh()
                            }
                            Task {
                                if let user = AuthManager.shared.user {
                                    await FirestoreManager.shared.saveUser(user: user)
                                }
                            }
                        } label: {
                            Image(fish.isPinned ? "anchor" : "anchorUnpinned")
                                .resizable()
                                .frame(width: 28, height: 34)
                                .scaleEffect(fish.isPinned ? 1 : 0.95)
                                .opacity(fish.isPinned ? 1 : 0.8)
                        }
                        .padding(.top)
                    }

                    Text(fish.description)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.65))
                        .lineLimit(2)

                    Spacer()

                    HStack {
                        Spacer()

                        Button {
                            showDeleteFishConfirm = true
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red.opacity(0.85))
                                .shadow(color: Color.red.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        .padding(.bottom)
                        .confirmationDialog("Delete this fish? This cannot be undone.",
                                            isPresented: $showDeleteFishConfirm,
                                            titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                let targetSize = fish.getSize()

                                if fish == user.speciesStore.pinnedDisplay {
                                    fish.isPinned.toggle()
                                    user.speciesStore.assignPinnedDisplay()
                                }

                                if fish.isAquarium {
                                    user.aquarium.removeFish(
                                        with: "\(species.name)Icon",
                                        targetSize: targetSize
                                    )
                                    user.aquarium.refresh()
                                }

                                species.fishList.removeAll { $0.id == fish.id }
                                Task {
                                    if let user = AuthManager.shared.user {
                                        await FirestoreManager.shared.saveUser(user: user)
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel) { }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

// Global Image extension to resolve local documents, Base64 strings, or Asset Catalog icons
extension Image {
    init(fishPhoto name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else {
            self.init(systemName: "photo")
            return
        }

        // 1. Asset Catalog (e.g. "HaddockIcon")
        if UIImage(named: clean) != nil {
            self.init(clean)
            return
        }

        // 2. Base64 String
        if let data = Data(base64Encoded: clean), let uiImage = UIImage(data: data) {
            self.init(uiImage: uiImage)
            return
        }

        // 3. Document Directory Filename
        let filename = URL(fileURLWithPath: clean).lastPathComponent
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(filename)
            if let uiImage = UIImage(contentsOfFile: fileURL.path) {
                self.init(uiImage: uiImage)
                return
            }
        }
        
        // 4. Direct File Path
        if let uiImage = UIImage(contentsOfFile: clean) {
            self.init(uiImage: uiImage)
            return
        }

        // 5. Fallback
        self.init(systemName: "photo")
    }
}

#Preview {
    let user = User()

    let sampleSpecies = Species(
        name: "European Pilchard",
        imageName: "europeanPilchardPhoto",
        icon: "clownfishIcon",
        fishList: []
    )

    NavigationStack {
        SpeciesListView(
            aquarium: user.aquarium,
            species: sampleSpecies
        )
    }
    .environmentObject(user)
}

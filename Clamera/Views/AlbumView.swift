//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
import Kingfisher

struct FishData: Codable, Identifiable {
    let id = UUID()
    let Species: String
    let CommonName: String
    let Image: String

    enum CodingKeys: String, CodingKey {
        case Species
        case CommonName
        case Image
    }
}

struct AlbumView: View {
    
    @EnvironmentObject var user: User
    
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var showHint: Bool = false
    @State private var activeLetter: Character? = "A"
    @State private var didSearchChange: Bool = false

    enum FilterOption: String, CaseIterable, Identifiable {
        case alphabetical = "Species"
        case caught = "Caught"
        case notCaught = "Uncaught"
        var id: String { rawValue }
    }

    @State private var selectedFilter: FilterOption = .caught
    
   
    var filteredSpecies: [Species] {
        var filtered = user.speciesStore.speciesList

        if !searchText.isEmpty {
            
            filtered = filtered.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        switch selectedFilter {
        case .alphabetical:
            filtered.sort { $0.name < $1.name }
            
        case .caught:
            filtered = filtered.filter { species in
                let hasFish = !species.fishList.isEmpty
                let speciesClean = species.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                
                let isUnlockedInStore = user.unlockedShopItems.contains { itemId in
                    let itemClean = itemId.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                    return itemClean.contains(speciesClean) || speciesClean.contains(itemClean)
                }
                return hasFish || isUnlockedInStore
            }
            filtered.sort { $0.name < $1.name }
            
        case .notCaught:
            filtered = filtered.filter { species in
                let hasFish = !species.fishList.isEmpty
                let speciesClean = species.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                
                let isUnlockedInStore = user.unlockedShopItems.contains { itemId in
                    let itemClean = itemId.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                    return itemClean.contains(speciesClean) || speciesClean.contains(itemClean)
                }
                return !hasFish && !isUnlockedInStore
            }
            filtered.sort { $0.name < $1.name }
        }

        return filtered
    }
    
    var sortedSpecies: [Species] {
        filteredSpecies.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    
    var availableLetters: [Character] {
        Set(
            sortedSpecies.compactMap { species in
                species.name.uppercased().first
            }
        )
        .sorted()
    }
    
    var body: some View {
        ZStack {
            
            ScrollViewReader { proxy in
                
                ScrollView {
                    VStack(spacing: 18) {
                        
                        Text("Album")
                            .font(.system(size: 34, weight: .bold))
                            .padding(.top, 20)
                        
                        Picker("", selection: $selectedFilter) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)

                        LazyVStack(spacing: 14) {
                            
                            if sortedSpecies.isEmpty {
                                Text("No fish found")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            } else {
                                
                                ForEach(sortedSpecies) { species in
                                    
                                    let letter = String(species.name.prefix(1)).uppercased()
                                    let hasFish = !species.fishList.isEmpty
                                    let speciesClean = species.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                                    let isUnlockedInStore = user.unlockedShopItems.contains { itemId in
                                        let itemClean = itemId.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                                        return itemClean.contains(speciesClean) || speciesClean.contains(itemClean)
                                    }
                                    
                                    Group {
                                        if hasFish || isUnlockedInStore {
                                            NavigationLink(
                                                destination: SpeciesListView(
                                                    aquarium: user.aquarium,
                                                    species: species
                                                )
                                            ) {
                                                SpeciesRow(species: species)
                                            }
                                        } else {
                                            SpeciesRow(species: species)
                                        }
                                    }
                                    .background(
                                        LetterTracker(letter: letter) { newLetter in
                                            if activeLetter != Character(newLetter) {
                                                activeLetter = Character(newLetter)
                                            }
                                        }
                                    )
                                    .id(species.id)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 120)
                    }
                }
                
                // ALPHABET OVERLAY (FILTERED)
                .overlay(alignment: .trailing) {
                    VStack(spacing: 2) {
                        ForEach(availableLetters, id: \.self) { letter in
                            
                            let isActive = activeLetter == letter
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 30, height: 16)
                                
                                Text(String(letter))
                                    .font(.system(size: isActive ? 14 : 11, weight: .bold))
                                    .foregroundColor(.black)
                                    .opacity(isActive ? 1.0 : 0.35)
                                    .scaleEffect(isActive ? 1.2 : 1.0)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                activeLetter = letter
                                scrollToLetter(letter, proxy: proxy)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                    .padding(.trailing, 4)
                }
            }
             
            // SEARCH BAR (UNCHANGED)
            .overlay(alignment: .bottom) {
                ZStack(alignment: .trailing) {
                    
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(.leading, 10)
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(40)
                            .shadow(color: .black.opacity(0.1), radius: 8)
                            .offset(y: showSearch ? -35 : 100)
                            .animation(.easeInOut, value: showSearch)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    Button {
                        withAnimation {
                            
                            showSearch.toggle()
                            
                            if showSearch == false {
                                
                                if didSearchChange {
                                    activeLetter = "A"
                                }
                                
                                didSearchChange = false
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    searchText = ""
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 55, height: 55)
                                .shadow(color: .black.opacity(0.08), radius: 4)
                                .opacity(showSearch ? 0 : 1)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                                .foregroundColor(.cyan)
                        }
                        .scaleEffect(showHint ? 1.05 : 1)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                showHint.toggle()
                            }
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 70)
                }
            }
        }
        .background(Color.blue.opacity(0.02))
    }

    // SCROLL
    func scrollToLetter(_ letter: Character, proxy: ScrollViewProxy) {
        if let match = sortedSpecies.first(where: {
            $0.name.uppercased().hasPrefix(String(letter))
        }) {
            withAnimation {
                proxy.scrollTo(match.id, anchor: .top)
            }
        }
    }
}

// grid that's passed a species for each item
struct SpeciesRow: View {
    
    @ObservedObject var species: Species
    @EnvironmentObject var user: User
    
    var body: some View {
        let hasFish = species.fishList.count > 0
        let speciesClean = species.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        
        let isUnlockedInStore = user.unlockedShopItems.contains { itemId in
            let itemClean = itemId.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            return itemClean.contains(speciesClean) || speciesClean.contains(itemClean)
        }
        
        let isAccessible = hasFish || isUnlockedInStore
         
        HStack(spacing: 16) {
             
            Image(UIImage(named: "\(species.name)Icon") != nil ? "\(species.name)Icon" : "Atlantic CodIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.cyan.opacity(isAccessible ? 0.08 : 0.03), radius: 2, x: 0, y: 1)
             
            VStack(alignment: .leading, spacing: 4) {
                 
                Text(species.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isAccessible ? .primary : .secondary)
                 
                if hasFish {
                    Text("\(species.fishList.count) Fish")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    if let heaviest = species.fishList.max(by: {
                        ($0.fishWeight ?? 0) < ($1.fishWeight ?? 0)
                    }) {
                        Text("Heaviest: \(heaviest.fishWeight ?? 0) lbs")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                } else if isUnlockedInStore {
                    Text("Unlocked via Shop")
                        .font(.system(size: 13))
                        .foregroundColor(.cyan)
                }
            }
             
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .foregroundStyle(isAccessible ? Color.cyan.opacity(0.2) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.cyan.opacity(isAccessible ? 0.15 : 0.08))
                )
                .shadow(color: Color.cyan.opacity(isAccessible ? 0.05 : 0.02), radius: 3, y: 1)
        )
    }
}

#Preview {
    AlbumView()
        .environmentObject(User())
}

struct LetterTracker: View {
    let letter: String
    let onChange: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                    if newValue < 200 && newValue > 0 {
                        onChange(letter)
                    }
                }
        }
    }
}

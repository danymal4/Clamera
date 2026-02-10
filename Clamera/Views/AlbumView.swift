//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//


//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

// MARK: - Models

struct Fish: Identifiable, Hashable {
    let id = UUID()
    let photo: String
    let speciesName: String
    let description: String = "cool fish I found with sam"
    let dateCaught: Date = Date()
    let isPinned: Bool = false
}

struct Species: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let icon: String = "clownfishIcon"
    let fishList: [Fish]

    var numberOfFish: Int { fishList.count }

    func getFishPhotos() -> [String] {
        fishList.map { $0.photo }
    }
}

// MARK: - Views

struct AlbumView: View {

    let speciesList = [
        Species(
            name: "Clownfish",
            imageName: "clownFishExample",
            fishList: [
                Fish(photo: "clownfish1", speciesName: "Clownfish"),
                Fish(photo: "clownfish2", speciesName: "Clownfish"),
                Fish(photo: "clownfish3", speciesName: "Clownfish"),
                Fish(photo: "nemo 1", speciesName: "Clownfish")
            ]
        ),
        Species(
            name: "Puffer",
            imageName: "pufferExample",
            fishList: [
                Fish(photo: "puffer1", speciesName: "Puffer"),
                Fish(photo: "puffer2", speciesName: "Puffer")
            ]
        ),
        Species(
            name: "Grouper",
            imageName: "grouperExample",
            fishList: [
                Fish(photo: "grouper1", speciesName: "Grouper"),
                Fish(photo: "grouper2", speciesName: "Grouper")
            ]
        ),
        Species(
            name: "Salmon",
            imageName: "salmonExample",
            fishList: []
        ),
        Species(
            name: "Cod",
            imageName: "codExample",
            fishList: []
        )
    ]

    // Two-column grid
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Search bar text
    @State private var searchText: String = ""

    // Filter options
    enum FilterOption: String, CaseIterable, Identifiable {
        case alphabetical = "Alphabetical"
        case caught = "Caught Fish"
        case notCaught = "Not Caught Fish"

        var id: String { self.rawValue }
    }

    @State private var selectedFilter: FilterOption = .alphabetical

    // Compute filtered species based on search + filter
    var filteredSpecies: [Species] {
        var filtered = speciesList

        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        // Apply filter options with alphabetical sorting
        switch selectedFilter {
        case .alphabetical:
            filtered.sort { $0.name < $1.name }
        case .caught:
            filtered = filtered.filter { !$0.fishList.isEmpty }
            filtered.sort { $0.name < $1.name }
        case .notCaught:
            filtered = filtered.filter { $0.fishList.isEmpty }
            filtered.sort { $0.name < $1.name }
        }

        return filtered
    }

    var body: some View {
        ZStack {
            WaterView()
                .offset(y: -180)
                .ignoresSafeArea()

            IconView()

            VStack(spacing: 20) {
                Text("Album")
                    .font(.custom("IslandMoments-Regular", size: 90))
                    .foregroundStyle(.blue)
                    .padding(.top)

                // Search + Filter HStack
                HStack(spacing: 10) {
                    // Search bar
                    HStack {
                        TextField("Search", text: $searchText)
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                        Spacer()
                    }
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.gray, lineWidth: 2)
                    )

                    // Filter menu button (icon + text stays visible)
                    Menu {
                        Button("Alphabetical") { selectedFilter = .alphabetical }
                        Button("Caught Fish") { selectedFilter = .caught }
                        Button("Not Caught Fish") { selectedFilter = .notCaught }
                    } label: {
                        VStack {
                            Image(systemName: "line.horizontal.3.decrease")
                            Text("Filter")
                                .font(.custom("HelveticaNeue-Thin", size: 15))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)

                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredSpecies) { item in
                            let hasFish = !item.fishList.isEmpty

                            Group {
                                if hasFish {
                                    NavigationLink(destination: SpeciesListView(species: item)) {
                                        SpeciesGridItem(species: item, clickable: true)
                                    }
                                } else {
                                    SpeciesGridItem(species: item, clickable: false)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }

            Spacer()

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.bottom, -500)
            }
        }
    }
}

// Grid item view
struct SpeciesGridItem: View {
    let species: Species
    let clickable: Bool

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(clickable ? 0.3 : 0.1))
                    .frame(
                        width: UIScreen.main.bounds.width * 0.38,
                        height: UIScreen.main.bounds.width * 0.33
                    )
                    .cornerRadius(15)

                Image(species.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: UIScreen.main.bounds.width * 0.35,
                        height: UIScreen.main.bounds.width * 0.3
                    )
                    .cornerRadius(10)
                    .clipped()
                    .opacity(clickable ? 1.0 : 0.4)
            }
            HStack {
                Text(species.name)
                    .font(Font(Constants.tabFont))
                    .bold()
                    .foregroundColor(clickable ? .black : .gray)

                if clickable {
                    Text("(\(String(species.numberOfFish)))")
                        .foregroundStyle(.black)
                        .opacity(0.4)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    NavigationStack {
        AlbumView()
    }
}

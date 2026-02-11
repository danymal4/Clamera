//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct Fish: Identifiable, Hashable {
    let id = UUID()
    let photo: String
    let speciesName: String
    let description: String = "cool fish I found with sam"
    let dateCaught: Date = Date()
    var isPinned: Bool = false
    var isAquarium: Bool = false
}

struct Species: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let icon: String
    let fishList: [Fish]

    var numberOfFish: Int { fishList.count }

    func getFishPhotos() -> [String] {
        fishList.map { $0.photo }
    }

    
    init(
        name: String,
        imageName: String,
        icon: String = "clownfishIcon", // default value
        fishList: [Fish]
    ) {
        self.name = name
        self.imageName = imageName
        self.icon = icon
        self.fishList = fishList
    }
}


import SwiftUI

struct AlbumView: View {

    @EnvironmentObject var aquarium: AquariumFishList

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
            icon: "pufferIcon",
            fishList: [
                Fish(photo: "puffer1", speciesName: "Puffer"),
                Fish(photo: "puffer2", speciesName: "Puffer")
            ],
        ),
        Species(
            name: "Grouper",
            imageName: "grouperExample",
            icon: "grouperIcon",
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

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State private var searchText: String = ""

    enum FilterOption: String, CaseIterable, Identifiable {
        case alphabetical = "Alphabetical"
        case caught = "Caught Fish"
        case notCaught = "Not Caught Fish"
        var id: String { self.rawValue }
    }

    @State private var selectedFilter: FilterOption = .alphabetical

    var filteredSpecies: [Species] {
        var filtered = speciesList

        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

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

                HStack(spacing: 10) {
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

                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredSpecies) { item in
                            let hasFish = !item.fishList.isEmpty

                            if hasFish {
                                NavigationLink(destination: SpeciesListView(species: item)) {
                                    SpeciesGridItem(species: item, clickable: true)
                                }
                            } else {
                                SpeciesGridItem(species: item, clickable: false)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }

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
        AlbumView().environmentObject(AquariumFishList())
       
    }
}

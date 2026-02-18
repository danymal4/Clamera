//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct Fish: Identifiable, Hashable {
    let id = UUID()
    var photo: String
    let speciesName: String
    var description: String = "cool fish I found with sam"
    let dateCaught: Date = Date()
    var isPinned: Bool = true
    var isAquarium: Bool = false
}

struct Species: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let icon: String
    var fishList: [Fish]

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

final class SpeciesStore: ObservableObject {
    @Published var speciesList: [Species] = [
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
            ]
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
        Species(name: "Salmon", imageName: "salmonExample", fishList: []),
        Species(name: "Cod", imageName: "codExample", fishList: [])
    ]
}



struct AlbumView: View {

    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore

    @State private var searchText: String = ""
    
    @State var showSuggestions: Bool = false
    
    
   


    enum FilterOption: String, CaseIterable, Identifiable {
        case alphabetical = "Alphabetical"
        case caught = "Caught Fish"
        case notCaught = "Not Caught Fish"
        var id: String { self.rawValue }
    }

    @State private var selectedFilter: FilterOption = .alphabetical
    
    
    var searchSuggestions: [Species] {
        if searchText.isEmpty { return [] }
        return Array(filteredSpecies.prefix(8))
    }


    var filteredSpecies: [Species] {
        var filtered = speciesStore.speciesList

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
            
            ScrollView {
              
                
                
                
                ZStack(alignment: .top) {
                    
                    
                    
                    Color.clear.frame(height: UIScreen.main.bounds.height)

                    WaterView()
                        .offset(y: -240)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .ignoresSafeArea()

                    IconView()
                    HStack {
                        Spacer()
                        Text("\(filteredSpecies.count) species").padding(.top, 150).font(.caption).opacity(0.3).padding(.horizontal, 110)
                    }
                    
                     if !searchSuggestions.isEmpty && showSuggestions {
                         VStack(spacing: 0) {
                             ForEach(searchSuggestions) { species in
                                 if let index = speciesStore.speciesList.firstIndex(where: { $0.id == species.id }) {
                                     
                                     NavigationLink(
                                         destination: SpeciesListView(
                                             aquarium: aquarium,
                                             speciesStore: speciesStore,
                                             speciesIndex: index
                                         )
                                     ) {
                                         HStack {
                                             Text(species.name)
                                                 .foregroundColor(.black)
                                                 .padding(.vertical, 10)
                                             Spacer()
                                         }
                                         .padding(.horizontal)
                                         .background(Color.white).cornerRadius(20)
                                     }.simultaneousGesture(TapGesture().onEnded {
                                         showSuggestions = false
                                     })


                                     Divider()
                                 }
                             }
                         }
                         .background(
                             RoundedRectangle(cornerRadius: 10)
                                 .fill(Color.white)
                                 .shadow(radius: 5)
                         )
                         .padding(.horizontal).padding(.top, 176)
                         .transition(.opacity)
                         .zIndex(1)
                     }
                    

                    VStack(spacing: 20) {
                        Text("Album")
                            .font(.custom("IslandMoments-Regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top)

                        // Search + filter bar
                        HStack(spacing: 10) {
                     

                            
                            HStack {
                                TextField("Search", text: $searchText)
                                    .foregroundColor(.black)
                                    .padding(.leading, 10).onChange(of: searchText) { newValue in
                                        showSuggestions = !newValue.isEmpty
                                    }

                                Spacer()
                            }
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray, lineWidth: 2)
                            )
                            Menu {
                                Button(selectedFilter == .alphabetical ? "Alphabetical  ✓" : "Alphabetical") {
                                    selectedFilter = .alphabetical
                                }
                                
                                Button(selectedFilter == .caught ? "Caught Fish  ✓" : "Caught Fish") {
                                    selectedFilter = .caught
                                }
                                
                                Button(selectedFilter == .notCaught ? "Not Caught Fish  ✓" : "Not Caught Fish") {
                                    selectedFilter = .notCaught
                                }
                            } label: {
                                VStack {
                                    Image(systemName: "line.horizontal.3.decrease")
                                        .foregroundStyle(.black)
                                    Text("Filter")
                                        .font(.custom("HelveticaNeue-Thin", size: 15))
                                        .foregroundStyle(.black)
                                }
                                .padding(.horizontal)
                            }

                        }
                        .padding(.horizontal)

                        // Species grid
                        ForEach(filteredSpecies) { item in
                            let hasFish = !item.fishList.isEmpty

                            if hasFish {
                                if let index = speciesStore.speciesList.firstIndex(where: { $0.id == item.id }) {
                                    // NavigationLink now works because HomerView's NavigationStack wraps Album tab
                                    NavigationLink(
                                        destination: SpeciesListView(
                                            aquarium: aquarium, speciesStore: speciesStore, speciesIndex: index
                                        )
                                    )
 {
                                        SpeciesGridItem(species: item, clickable: true)
                                    }
                                }
                            } else {
                                SpeciesGridItem(species: item, clickable: false)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Bottom overlay
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
}

// Reusable species grid item
struct SpeciesGridItem: View {
    let species: Species
    let clickable: Bool

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(clickable ? 0.3 : 0.1))
                    .frame(
                        width: UIScreen.main.bounds.width * 0.88,
                        height: UIScreen.main.bounds.width * 0.83
                    )
                    .cornerRadius(15)

                Image(species.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: UIScreen.main.bounds.width * 0.85,
                        height: UIScreen.main.bounds.width * 0.8
                    )
                    .cornerRadius(10)
                    .clipped()
                    .opacity(clickable ? 1.0 : 0.4)
            }

            HStack {
                Text(species.name)
                    .font(.system(size: UIScreen.main.bounds.width * 0.07))
                    .bold()
                    .foregroundColor(clickable ? .black : .gray)
                    .opacity(0.7)

                if clickable {
                    Text("(\(species.numberOfFish))")
                        .foregroundStyle(.black)
                        .font(.system(size: UIScreen.main.bounds.width * 0.05))
                        .opacity(0.4)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    AlbumView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
}

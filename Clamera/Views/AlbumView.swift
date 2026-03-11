//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
import Kingfisher

// codable since it absorbs data directly from fish data json
struct FishData: Codable, Identifiable {
    let id = UUID()
    let Species: String        // Scientific name
    let CommonName: String     // Human-friendly name
    let Image: String          // URL of image
}

struct AlbumView: View {

    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore

    @State private var searchText: String = ""
    @State private var showSuggestions: Bool = false
    @State private var showSearch: Bool = false
    @State private var showHint: Bool = false

    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case alphabetical = "Alphabetical"
        case caught = "Caught Fish"
        case notCaught = "Not Caught Fish"
        var id: String { rawValue }
    }

    @State private var selectedFilter: FilterOption = .alphabetical
    
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

        var seen = Set<String>()
        filtered = filtered.filter { species in
            if seen.contains(species.name) {
                return false
            } else {
                seen.insert(species.name)
                return true
            }
        }

        return filtered
    }

    var body: some View {
        ZStack {
            ScrollView {
                ZStack(alignment: .top) {
                    Color.clear.frame(height: UIScreen.main.bounds.height)
                 
                    
                    VStack(spacing: 20) {
                        Text("Album")
                            .font(.system(size: 34, weight: .bold))
                            .padding(.top, 20)
                        
                        ZStack {
                            HStack {}.background(
                                RoundedRectangle(cornerRadius: 25)
                                    .colorInvert()
                                    .frame(width: UIScreen.main.bounds.width * 0.8575, height: UIScreen.main.bounds.width * 0.13)
                                    .shadow(color: .black.opacity(0.1), radius: 10)
                            )
                            HStack {
                                filterButton(title: "Species", filter: .alphabetical)
                                filterButton(title: "Caught", filter: .caught)
                                filterButton(title: "Uncaught", filter: .notCaught)
                            }
                        }
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(filteredSpecies) { item in
                                let hasFish = item.fishList.isEmpty
                                
                                if !hasFish {
                                    if let index = speciesStore.speciesList.firstIndex(where: { $0.id == item.id }) {
                                        NavigationLink(
                                            destination: SpeciesListView(
                                                aquarium: aquarium,
                                                species: speciesStore.speciesList[index]
                                            ).navigationBarTitleDisplayMode(.inline)
                                                .tint(.black)
                                        )   {
                                            SpeciesGridItem(species: speciesStore.speciesList[index], clickable: true)
                                        }
                                    }
                                } else {
                                    SpeciesGridItem(species: item, clickable: false)
                                }
                            }
                        }.padding(.horizontal, 15)
                    }
                }
            }
            
            VStack {
                Spacer()
                Spacer()
                
                ZStack(alignment: .trailing) {
                    HStack {
                        TextField("Search", text: $searchText)
                            .foregroundColor(.black)
                            .padding(.leading, 5)
                            .frame(height: 55)
                            .background(Color.white.opacity(1))
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .cornerRadius(40)
                            .offset(y: showSearch ? -35 : 100)
                            .animation(.easeInOut(duration: 0.3), value: showSearch)
                            .onChange(of: searchText) { newValue in
                                showSuggestions = !newValue.isEmpty
                            }
                        Spacer()
                    }.padding(.horizontal, 15)
                  
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSearch.toggle()
                            searchText = ""
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 55, height: 55) // adjust size to your liking
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 28))
                                .foregroundColor(.cyan)
                               
                                .shadow(color: Color.cyan.opacity(0.2), radius: 3, x: 0, y: 1)
                                
                        }.onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                showHint.toggle()
                            }
                        } .scaleEffect(showHint ? 1.06 : 1.0)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 70)
                }
            }
        }
        .background(Color.blue.opacity(0.01))
    }
    
    @ViewBuilder
    private func filterButton(title: String, filter: FilterOption) -> some View {
        Button {
            selectedFilter = filter
        } label: {
            ZStack {
                if selectedFilter == filter { SmallRoundedCard() }
                else { SmallRoundedCard().opacity(0.0) }
                Text(title)
                    .foregroundStyle(selectedFilter == filter ? .cyan : .secondary) // active = cyan, inactive = subtle gray
                    .fontWeight(selectedFilter == filter ? .semibold : .regular)
            }
        }
    }
}

// grid that's passed a species for each item 
struct SpeciesGridItem: View {
    @ObservedObject var species: Species
    let clickable: Bool
    
    private var cardWidth: CGFloat { UIScreen.main.bounds.width * 0.45 }
    private var cardHeight: CGFloat { cardWidth }
    
    var body: some View {
        ZStack {
          
            // special package I added from chat since I couldnt get the data to load consistently well (KF caches image data so it only has to load once per usage of the app)
            ZStack {
                // MARK: - Blurred Background
                KFImage(URL(string: species.imageName.trimmingCharacters(in: .whitespacesAndNewlines)))
                    .placeholder {
                        Image("stockPhoto")
                            .resizable()
                            .scaledToFill()
                    }
                    .retry(maxCount: 3, interval: .seconds(5))
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth * 0.95, height: cardHeight * 0.95)
                    .blur(radius: 10)
                    .opacity(0.45)
                    .clipped()
                
                // MARK: - Fish Image (stretched to fill frame)
                KFImage(URL(string: species.imageName.trimmingCharacters(in: .whitespacesAndNewlines)))
                    .placeholder {
                        Image("stockPhoto")
                            .resizable()
                    }
                    .retry(maxCount: 3, interval: .seconds(5))
                    .resizable()
                    .frame(width: cardWidth * 0.95, height: cardHeight * 0.95) // forces the frame
                    .clipped()
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            }
            .frame(width: cardWidth * 0.95, height: cardHeight * 0.95)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemGray5))
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .opacity(clickable ? 1.0 : 0.6)
            .brightness(clickable ? -0.15 : 0)
           
            
            HStack(spacing: 4) {
                let imageName = "\(species.name)Icon"
                let imageExists = UIImage(named: imageName) != nil

                Text(species.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(imageExists ? .white : .white)
                    .shadow(color: clickable ? Color.cyan.opacity(0.6) : .clear, radius: 4, x: 0, y: 0)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .allowsTightening(true)
                
                if clickable {
                    Text("(\(species.fishList.count))")
                        .foregroundStyle(.white)
                        .font(.system(size: UIScreen.main.bounds.width * 0.035))
                }
                
                Spacer()
            }
            .padding(.top, 135)
            .padding(.horizontal, 30)
        }
        .shadow(color: .black.opacity(0.1), radius: 20)
    }
}


#Preview {
    AlbumView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
}

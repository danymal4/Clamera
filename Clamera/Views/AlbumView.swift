//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
import Kingfisher

// MARK: - Fish JSON Structure
// MARK: - Fish JSON Structure (Matches fish_data.json)
struct FishData: Codable, Identifiable {
    let id = UUID()
    let Species: String        // Scientific name
    let CommonName: String     // Human-friendly name
    let Image: String          // URL of image
}

// MARK: - Album View
// MARK: - Album View
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
                    IconView()
                    
                    VStack(spacing: 20) {
                        Text("Album")
                            .font(.custom("AkayaTelivigala-regular", size: 50))
                            .foregroundStyle(.blue)
                            .padding(.top)
                            .opacity(0.8)
                        
                        ZStack {
                            HStack {}.background(
                                RoundedRectangle(cornerRadius: 20)
                                    .colorInvert()
                                    .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.width * 0.13)
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
                                            )
                                        ) {
                                            SpeciesGridItem(species: speciesStore.speciesList[index], clickable: true) // ✅ pass ObservedObject
                                        }
                                    }
                                } else {
                                    SpeciesGridItem(species: item, clickable: false) // ✅ also observed
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
                            .offset(y: showSearch ? 0 : 100) // ✅ Slide up from offscreen
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
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                            .scaleEffect(showHint ? 1.06 : 1.0)
                            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 1)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                    showHint.toggle()
                                }
                            }
                    }
                    .padding(.trailing, 35)
                    .padding(.bottom, 10)
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
                Text(title).foregroundStyle(Color.black).opacity(0.7)
            }
        }
    }
}

// MARK: - Species Grid Item
struct SpeciesGridItem: View {
    @ObservedObject var species: Species // ✅ change here
    let clickable: Bool
    
    private var cardWidth: CGFloat { UIScreen.main.bounds.width * 0.45 }
    private var cardHeight: CGFloat { cardWidth }
    
    var body: some View {
        ZStack {
            KFImage(
                URL(string: species.imageName.trimmingCharacters(in: .whitespacesAndNewlines))
            )
            .placeholder {
                Image("stockPhoto")
                    .resizable()
                    .scaledToFill()
            }
            .retry(maxCount: 3, interval: .seconds(5))
            .resizable()
            .scaledToFill()
            .frame(width: cardWidth * 0.95, height: cardHeight * 0.95)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemGray5))
            )
            .cornerRadius(25)
            .opacity(clickable ? 1.0 : 0.6)
            .brightness(clickable ? -0.15 : 0)
            
            HStack(spacing: 4) {
                let imageName = "\(species.name)Icon"
                let imageExists = UIImage(named: imageName) != nil

                Text(species.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(imageExists ? .blue : .white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .allowsTightening(true)
                
                if clickable {
                    Text("(\(species.fishList.count))") // ✅ now updates live
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

// MARK: - Preview
#Preview {
    AlbumView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
}

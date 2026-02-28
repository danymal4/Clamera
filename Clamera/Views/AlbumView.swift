//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI


// MARK: - Fish Model
struct Fish: Identifiable, Hashable {
    let id = UUID()
    var photo: String
    let speciesName: String
    var description: String = "cool fish I found with sam"
    var dateCaught: Date = Date()
    var isPinned: Bool = true
    var isAquarium: Bool = false
    var fishWeight: Int?
}

// MARK: - Species Model
struct Species: Identifiable, Hashable {
    let id: String   // stable ID = species name
    let name: String
    let imageName: String
    let icon: String
    var fishList: [Fish]

    var numberOfFish: Int { fishList.count }

    func getFishPhotos() -> [String] {
        fishList.map { $0.photo }
    }

    init(name: String, imageName: String, icon: String = "clownfishIcon", fishList: [Fish] = []) {
        self.id = name
        self.name = name
        self.imageName = imageName
        self.icon = icon
        self.fishList = fishList
    }
}

// MARK: - Fish JSON Structure
// MARK: - Fish JSON Structure (Matches fish_data.json)
struct FishData: Codable, Identifiable {
    let id = UUID()
    let Species: String        // Scientific name
    let CommonName: String     // Human-friendly name
    let Image: String          // URL of image
}

// MARK: - Species Store
final class SpeciesStore: ObservableObject {
    
    @Published var speciesList: [Species] = []
    @Published var totalClamPoints: Int = 0
    
    init() {
        loadFromJSON()
    }
    
    private func loadFromJSON() {
        guard let url = Bundle.main.url(forResource: "fish_data", withExtension: "json") else {
            print("❌ Could not find fish_data.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([FishData].self, from: data)
            
            // Map FishData → Species
            self.speciesList = decoded.map { fish in
                Species(
                    name: fish.CommonName,      // Use CommonName for display
                    imageName: fish.Image,      // Image URL
                    fishList: []                // Empty unless user caught one
                )
            }
            
            print("✅ Loaded \(speciesList.count) species")
        } catch {
            print("❌ JSON decode error:", error)
        }
    }
    
    // MARK: - Clam Points Logic
    func calculateClamPoints(
        totalOfSpecies caughtFish: Int,
        totalOtherFish otherFish: Int,
        previousFishDate: Date? = nil
    ) -> Int {
        guard caughtFish > 0 else { return 0 }
        let safeOtherFish = max(otherFish, 0)
        if caughtFish == 1 { return 90 }

        let caughtMinRaw = 15 + abs(Double(safeOtherFish - 5) / 3.0)
        let caughtMin = min(caughtMinRaw, 30)
        guard caughtMin > 2 else { return 50 }

        let pointsRaw = 50 - Double(caughtFish - 2) * (30 / (caughtMin - 2))
        let speciesPoints = max(pointsRaw, 20)

        var timeBonus: Double = 0
        if let prevDate = previousFishDate {
            let daysSincePrevious = Calendar.current.dateComponents([.day], from: prevDate, to: Date()).day ?? 0
            let rawTimeBonus = 12.0 * log(Double(daysSincePrevious) + 1) / log(61.0)
            timeBonus = min(rawTimeBonus, 12.0)
        }

        return Int((speciesPoints + timeBonus).rounded())
    }
    
    // MARK: - Stats
    func getSpecies() -> Int {
        speciesList.filter { !$0.fishList.isEmpty }.count
    }
    
    func getFish() -> Int {
        speciesList.reduce(0) { $0 + $1.fishList.count }
    }
}

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

        // Apply search text
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        // Apply filter option
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

        // Remove duplicates (keep first occurrence)
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
                    
                    HStack {
                        Spacer()
                        Text("\(filteredSpecies.count) species")
                            .padding(.top, 150)
                            .font(.caption)
                            .opacity(0.3)
                            .padding(.horizontal, 110)
                            .padding(.top, 5)
                    }
                    
                    VStack(spacing: 20) {
                        Text("Album")
                            .font(.custom("AkayaTelivigala-regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top)
                            .opacity(0.8)
                        
                        // Filter bar
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
                                                speciesStore: speciesStore,
                                                speciesIndex: index
                                            )
                                        ) {
                                            SpeciesGridItem(species: item, clickable: true)
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
                            .background(Color.white.opacity(0.95).overlay(Color.blue.opacity(0.06)))
                            .cornerRadius(40)
                            .opacity(showSearch ? 1 : 0)
                            .onChange(of: searchText) { newValue in
                                showSuggestions = !newValue.isEmpty
                            }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .offset(y: showSearch ? -5 : 100)
                    .animation(.easeInOut(duration: 0.3), value: showSearch)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSearch.toggle()
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
                
                Rectangle()
                    .fill(Color.white)
                    .overlay(Color.blue.opacity(0.06))
                    .frame(height: 83)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.bottom, -300)
                    .shadow(color: .black.opacity(0.1), radius: 10)
            }
        }
        .background(Color.blue.opacity(0.08))
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


struct SpeciesGridItem: View {
    let species: Species
    let clickable: Bool
    
    private var cardWidth: CGFloat { UIScreen.main.bounds.width * 0.45 }
    private var cardHeight: CGFloat { cardWidth }
    
    var body: some View {
        ZStack {
            // Trim spaces/newlines from image URL
            if let url = URL(string: species.imageName.trimmingCharacters(in: .whitespacesAndNewlines)) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let image):
                        ZStack {
                            // Background for transparent images
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(.systemGray5))   // or .white, or custom color
                                .frame(width: cardWidth * 0.95, height: cardHeight * 0.95)

                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: cardWidth * 0.95, height: cardHeight * 0.95)
                                .clipped()
                                .cornerRadius(25)
                                .brightness(clickable ? -0.15 : 0)
                                .opacity(clickable ? 1.0 : 0.6)
                        }
                    
                         
                    case .failure:
                        // Show fallback image or color
                        Image("stockPhoto")   .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth * 0.95, height: cardHeight * 0.95).cornerRadius(25) .brightness( clickable ? -0.15 : 0) .opacity(clickable ? 1.0 : 0.6)
                    @unknown default:
                        Color.gray
                    }
                }
            } else {
                // Invalid URL fallback
              
                    Image("stockPhoto")
            }
            
            HStack(spacing: 4) {
                Text(species.name)
                    .font(.system(size: 18, weight: .bold))   // base size
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)                  // allows shrinking to 50%
                    .lineLimit(2)                             // keep it on one line
                    .allowsTightening(true)                   // slightly tighter spacing if needed
                
                if clickable {
                    Text("(\(species.numberOfFish))")
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

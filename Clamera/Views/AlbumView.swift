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
    var dateCaught: Date = Date()
    var isPinned: Bool = true
    var isAquarium: Bool = false
    var fishWeight: Int = 0
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
                Fish(photo: "clownfish1", speciesName: "Clownfish", dateCaught: Date().addingTimeInterval(-86400 * 3)),
                Fish(photo: "clownfish2", speciesName: "Clownfish", dateCaught: Date().addingTimeInterval(-86400 * 2)),
                Fish(photo: "clownfish3", speciesName: "Clownfish", dateCaught: Date().addingTimeInterval(-86400)),
                Fish(photo: "nemo 1", speciesName: "Clownfish", dateCaught: Date())
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
        Species(name: "Cod", imageName: "codExample", icon: "codIcon", fishList: [])
    ]
    @Published var totalClamPoints : Int = 0
    
    
    
    // clam points calc logic
   
    func calculateClamPoints(
        totalOfSpecies caughtFish: Int,
        totalOtherFish otherFish: Int,
        previousFishDate: Date? = nil
    ) -> Int {
        
        // Step 0: First catch always gives 90 points
        if caughtFish == 1 {
            let totalPoints = 90
            totalClamPoints += totalPoints
            return totalPoints
        }
        
        // Step 1: Calculate caughtMin (like codMin)
        let caughtMinRaw = 15 + abs(Double(otherFish - 5) / 3.0)
        let caughtMin = min(caughtMinRaw, 30)
        
        // Prevent divide by zero
        guard caughtMin > 2 else {
            totalClamPoints += 50
            return 50
        }
        
        // Step 2: Base species points
        let pointsRaw = 50 - Double(caughtFish - 2) * (30 / (caughtMin - 2))
        let speciesPoints = max(pointsRaw, 20)
        
        // Step 3: Time bonus
        var timeBonus: Double = 0
        if let prevDate = previousFishDate {
            let daysSincePrevious = Calendar.current.dateComponents([.day], from: prevDate, to: Date()).day ?? 0
            let rawTimeBonus = 12.0 * log(Double(daysSincePrevious) + 1) / log(61.0)
            timeBonus = min(rawTimeBonus, 12.0)
        }
        
        // Step 4: Total points
        let totalPoints = speciesPoints + timeBonus
        
        // Update published totalClamPoints
        totalClamPoints += Int(totalPoints.rounded())
        
        return Int(totalPoints.rounded())
    }
    
    
    func getSpecies() -> Int {
     
        var total: Int = 0
        
        for species in speciesList {
            if species.fishList.count > 0 {
                total += 1
            }
        }
        
        
        
        return total
    }
    
  
    
    func getFish() -> Int {
        
        var total: Int = 0
        
        for species in speciesList {
            total += species.fishList.count
        }
        
        
        
        return total
    }

    
}



struct AlbumView: View {

    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore

    @State private var searchText: String = ""
    
    @State var showSuggestions: Bool = false
    @State var showSearch: Bool = false
    @State var showHint: Bool = false
    
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

 
   


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
                    
                    
                    WaterView().opacity(0.3)
                    
                    IconView()
                    HStack {
                        Spacer()
                        Text("\(filteredSpecies.count) species").padding(.top, 150).font(.caption).opacity(0.3).padding(.horizontal, 110).padding(.top, 5)
                    }
                    
                 
                    
                    VStack(spacing: 20) {
                        Text("Album")
                            .font(.custom("AkayaTelivigala-regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top).opacity(0.8)
                        
                        // Search + filter bar
                        ZStack {
                            
                            
                            
                            HStack {
                            
                                
                                
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20).colorInvert()  .frame(
                                    width: UIScreen.main.bounds.width * 0.85,
                                    height: UIScreen.main.bounds.width * 0.13
                                )  .shadow(color: .black.opacity(0.1), radius: 10)
                                
                            )
                            HStack {
                                Button {
                                    selectedFilter = .alphabetical
                                }
                                label : {
                                    
                                    ZStack{
                                        
                                        if  selectedFilter == .alphabetical {
                                            
                                            
                                            SmallRoundedCard()
                                            
                                        }
                                        
                                        else {
                                            SmallRoundedCard().opacity(0.0)
                                            
                                        }
                                        Text("Species").foregroundStyle(Color.black).opacity(0.7)
                                    }
                                    
                                }
                                
                                Button {
                                    selectedFilter = .caught
                                }
                                
                                label: {
                                    
                                    ZStack{
                                        
                                        if selectedFilter == .caught {
                                            
                                            SmallRoundedCard()
                                            
                                            
                                        }
                                        
                                        else {
                                            SmallRoundedCard().opacity(0.0)
                                            
                                        }
                                        
                                        Text("Caught").foregroundStyle(Color.black).opacity(0.7)
                                    }
                                }
                                
                                Button {
                                    selectedFilter = .notCaught
                                    
                                } label: {
                                    
                                    ZStack{
                                        
                                        
                                        if selectedFilter == .notCaught {
                                            
                                            SmallRoundedCard()
                                            
                                        }
                                        
                                        else {
                                            
                                            SmallRoundedCard().opacity(0.0)
                                            
                                        }
                                        
                                        Text("Uncaught").foregroundStyle(Color.black).opacity(0.7)
                                        
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            
                            
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
                           
                        }.padding(.horizontal, 15)
                    }}
            }

      
            VStack {
                Spacer()
                Spacer()

                ZStack(alignment: .trailing) {

                    // Background + TextField animates up
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

                        Spacer() // Keep TextField on the left
                    }
                    .padding(.horizontal, 20)
                    .offset(y: showSearch ? -5 : 100) // Animate from below
                    .animation(.easeInOut(duration: 0.3), value: showSearch)

                    // Magnifying glass stays fixed
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
                                withAnimation(
                                    .easeInOut(duration: 1)
                                        .repeatForever(autoreverses: true)
                                ) {
                                   
                                                                            showHint.toggle()
                                    
                                    
                                   
                                        
                                      
                                    
                                }
                            }
                    }
                    .padding(.trailing, 35)
                    .padding(.bottom, 10) // Slightly above bottom rectangle
                }

                // Bottom rectangle stays fixed
                Rectangle()
                    .fill(Color.white)
                    .overlay(Color.blue.opacity(0.06))
                    .frame(height: 83)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.bottom, -300)
            }
        }.background(Color.blue.opacity(0.08))
    }
}





struct SpeciesGridItem: View {
    let species: Species
    let clickable: Bool
    
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width * 0.45   // ~2 columns with spacing
    }
    
    private var cardHeight: CGFloat {
        cardWidth
    }

    var body: some View {
        ZStack {
            ZStack {
             
             
                HStack{
                 
             
                    Image(species.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: cardWidth * 0.95,
                            height: cardHeight * 0.95
                        )
                        .cornerRadius(25)
                        .clipped()
                        .opacity(clickable ? 1.0 : 0.4) .shadow(color: .black.opacity(0.1), radius: 20)
                
                   
                }
            }

            HStack(spacing: 4) {
                
                
                Text(species.name)
                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                    .bold()
                    .foregroundColor(clickable ? .white : .gray)
                  
                
                if clickable {
                    Text("(\(species.numberOfFish))")
                        .foregroundStyle(.white)
                        .font(.system(size: UIScreen.main.bounds.width * 0.035))
                        .opacity(0.8)
                }
             
                Spacer()
                
            }.padding(.top, 135).padding(.horizontal, 30)
        }
     
    }
}


#Preview {
    AlbumView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
}

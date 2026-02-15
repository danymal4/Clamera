//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
struct FishCardView: View {
    let imageName: String
    let animate: Bool // true for unpinned, false for pinned
    
    var body: some View {
        ZStack {
            
            // Base rectangle
            RoundedRectangle(cornerRadius: 15)
                .frame(
                    width: UIScreen.main.bounds.width * 0.88,
                    height: UIScreen.main.bounds.width * 0.83
                )
                .foregroundStyle(Color.white.opacity(0.3))
                .scaleEffect(animate ? 1.035 : 1.0)
            
            if animate {
                RoundedRectangle(cornerRadius: 15)
                    .frame(
                        width: UIScreen.main.bounds.width * 0.88,
                        height: UIScreen.main.bounds.width * 0.83
                    )
                    .foregroundStyle(Color.mint)
                    .opacity(animate ? 0.5 : 0.0)
                    .scaleEffect(animate ? 1.035 : 1.0)
            }
            
            // Fish image
            Image(fishPhoto: imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width * 0.85,
                    height: UIScreen.main.bounds.width * 0.8
                )
                .cornerRadius(10)
                .clipped()
                .scaleEffect(animate ? 1.035 : 1.0)
        }
        .animation(
            animate
            ? .easeInOut(duration: 2.2).repeatForever(autoreverses: true)
            : .default,
            value: animate
        )
    }
}



extension Image {
    /// Loads an image either from the app bundle (assets) or the documents folder
    init(fishPhoto name: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
        
        if let uiImage = UIImage(contentsOfFile: url.path) {
            self.init(uiImage: uiImage)
        } else {
            self.init(name) // fallback to asset catalog image
        }
    }
}


struct SpeciesListView: View {

    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore
   
    let speciesIndex: Int
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case oldest = "Oldest"
        case newest = "Newest"
        
        var id: String { self.rawValue }
    }

    @State private var selectedFilter: FilterOption = .oldest

    var species: Species {
        speciesStore.speciesList[speciesIndex]
    }
    
    // Filtered fish list (THIS is what actually drives UI now)
    var filteredFish: [Fish] {
        var fish = speciesStore.speciesList[speciesIndex].fishList
        
        switch selectedFilter {
        case .oldest:
            break
            
        case .newest:
            fish.reverse()
        }
        
        return fish
    }

    var body: some View {
        
        ZStack {

            ScrollView {

                ZStack(alignment: .top) {

                    WaterView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(y: -310)

                    IconView()
                    
                    Menu {
                        Button("Oldest") { selectedFilter = .oldest }
                        Button("Newest") { selectedFilter = .newest }
                    } label: {
                       Spacer()
                        
                        HStack{
                            VStack {
                                Image(systemName: "line.horizontal.3.decrease")
                                    .foregroundStyle(.black)
                                Text("Filter")
                                    .font(.custom("HelveticaNeue-Thin", size: 15))
                                    .foregroundStyle(.black)
                            }
                            .padding(.horizontal).padding(.top, 75)
                        }
                        }

                    VStack(spacing: 20) {

                        Text(species.name)
                            .font(.custom("IslandMoments-Regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top)

                        ForEach(filteredFish) { fish in
                            
                            // Get binding to real fish
                            if let realSpeciesIndex = speciesStore.speciesList.firstIndex(where: { $0.id == species.id }),
                               let fishIndex = speciesStore.speciesList[realSpeciesIndex]
                                    .fishList.firstIndex(where: { $0.id == fish.id }) {
                                
                                let fishBinding = $speciesStore
                                    .speciesList[realSpeciesIndex]
                                    .fishList[fishIndex]
                                
                                VStack {
                                    
                                    NavigationLink(
                                        destination: FishDetailsView(fishID: fish.id)
                                            .environmentObject(speciesStore)
                                            .environmentObject(aquarium)
                                    ) {
                                        FishCardView(
                                            imageName: fish.photo,
                                            animate: !fish.isPinned
                                        )
                                    }

                                    Text("5/30")
                                        .bold()
                                        .font(.system(size: UIScreen.main.bounds.width * 0.05))
                                        .opacity(0.7)
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }

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

#Preview {
    let store = SpeciesStore()
    NavigationStack {
        SpeciesListView(speciesIndex: 0)   
            .environmentObject(store)
            .environmentObject(AquariumFishList())
    }
}


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
    
    @State private var scale: CGFloat = 1.0
    @State private var overlayOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Base rectangle: always low opacity white
            RoundedRectangle(cornerRadius: 15)
                .frame(
                    width: UIScreen.main.bounds.width * 0.88,
                    height: UIScreen.main.bounds.width * 0.83
                )
                .foregroundStyle(Color.white.opacity(0.3))
                .scaleEffect(scale) // matches image bulge
            
            
            if animate {
                RoundedRectangle(cornerRadius: 15)
                    .frame(
                        width: UIScreen.main.bounds.width * 0.88,
                        height: UIScreen.main.bounds.width * 0.83
                    )
                    .foregroundStyle(Color.mint)
                    .opacity(overlayOpacity)
                    .scaleEffect(scale)
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
                .scaleEffect(scale)
        }
        .onAppear {
            guard animate else { return } // only animate for unpinned fish
            
            // Bulge animation
            withAnimation(
                .easeInOut(duration: 2.2)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.035
            }
            
            // Blue overlay pulse animation
            withAnimation(
                .easeInOut(duration: 2.2)
                .repeatForever(autoreverses: true)
            ) {
                overlayOpacity = 0.5 // subtle pulse
            }
        }
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

    var species: Species {
        speciesStore.speciesList[speciesIndex]
    }


    // Binding to the species in the store to propagate changes
    var speciesBinding: Binding<Species>? {
        guard let index = speciesStore.speciesList.firstIndex(where: { $0.id == species.id }) else {
            return nil
        }
        return $speciesStore.speciesList[index]
    }

    var body: some View {
        ZStack {

            ScrollView {

                ZStack(alignment: .top) {

                    // Background water
                    WaterView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(y: -310)

                    // Top icon
                    IconView()

                    VStack(spacing: 20) {

                        // Title
                        Text(species.name)
                            .font(.custom("IslandMoments-Regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top)

                        // Fish list
                        if let speciesIndex = speciesStore.speciesList.firstIndex(where: { $0.id == species.id }) {
                            ForEach(speciesStore.speciesList[speciesIndex].fishList.indices, id: \.self) { fishIndex in
                                let fishBinding = $speciesStore.speciesList[speciesIndex].fishList[fishIndex]
                                VStack {
                                    NavigationLink(
                                        destination: FishDetailsView(fishID: fishBinding.id)
                                            .environmentObject(speciesStore)
                                            .environmentObject(aquarium)
                                    ) {
                                        FishCardView(
                                            imageName: fishBinding.photo.wrappedValue,
                                            animate: !fishBinding.isPinned.wrappedValue
                                        )
                                    }


                                    Text("5/30")
                                        .bold()
                                        .font(.system(size: UIScreen.main.bounds.width * 0.05))
                                        .opacity(0.7)
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal)

                                .padding(.vertical, 5)
                                .padding(.horizontal)
                            }
                        }
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

#Preview {
    let store = SpeciesStore()
    NavigationStack {
        SpeciesListView(speciesIndex: 0)   
            .environmentObject(store)
            .environmentObject(AquariumFishList())
    }
}


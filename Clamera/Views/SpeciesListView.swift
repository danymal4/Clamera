//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI


struct SpeciesListView: View {

    @EnvironmentObject var aquarium: AquariumFishList
    let species: Species

    var body: some View {
        ZStack {

            ScrollView {

                ZStack(alignment: .top) {

                    // Background water (same format as AlbumView)
                    WaterView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(y: -230)

                    // Top icon
                    IconView()

                    VStack(spacing: 20) {

                        // Title
                        Text(species.name)
                            .font(.custom("IslandMoments-Regular", size: 90))
                            .foregroundStyle(.blue)
                            .padding(.top)

                        // Fish list
                        ForEach(species.fishList) { fish in
                            VStack {

                                ZStack {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(
                                            width: UIScreen.main.bounds.width * 0.88,
                                            height: UIScreen.main.bounds.width * 0.83
                                        )
                                        .cornerRadius(15)

                                    NavigationLink(
                                        destination: FishDetailsView(fish: fish)
                                    ) {
                                        Image(fish.photo)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                width: UIScreen.main.bounds.width * 0.85,
                                                height: UIScreen.main.bounds.width * 0.8
                                            )
                                            .cornerRadius(10)
                                            .clipped()
                                    }
                                }

                                Text("5/30")
                                    
                                    .bold()  .font(.system(size: UIScreen.main.bounds.width * 0.05)).opacity(0.7)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                        }
                    }
                }
            }

            // Bottom white overlay (same as AlbumView)
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
    NavigationStack {
        SpeciesListView(
            species: Species(
                name: "Clownfish",
                imageName: "clownFishExample",
                fishList: [
                    Fish(photo: "clownfish1", speciesName: "Clownfish"),
                    Fish(photo: "clownfish2", speciesName: "Clownfish")
                ]
            )
        )
       
    }
}

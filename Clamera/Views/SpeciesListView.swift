//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
import SwiftUI

struct SpeciesListView: View {
    
    let species: Species
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background water (unchanged)
            WaterView()
                .offset(y: -240)
                .ignoresSafeArea()
            
            IconView()
                .padding(.top, 80)
            
            // Title & filter (unchanged)
            ZStack {
                Text(species.name)
                    .font(.custom("IslandMoments-Regular", size: 90))
                    .foregroundStyle(.blue)
                
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "line.horizontal.3.decrease")
                        Text("Filter")
                            .font(.custom("HelveticaNeue-Thin", size: 15))
                    }.padding(.top, 300)
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 600)
            
            // Grid with soft background zone
            VStack {
                ZStack {
                    // Soft background extending beyond the grid
                    RoundedRectangle(cornerRadius: 35)
                        .fill(Color.white.opacity(0.15))
                        .frame(
                            width: UIScreen.main.bounds.width * 0.95,
                            height: UIScreen.main.bounds.width * 1.15 // taller than grid
                        )
                        .blur(radius: 0.3)
                    
                    // Scrollable grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(species.fishList) { fish in
                                VStack {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(
                                                width: UIScreen.main.bounds.width * 0.38,
                                                height: UIScreen.main.bounds.width * 0.33
                                            )
                                            .cornerRadius(15)
                                        
                                        // NavigationLink remains
                                        NavigationLink(
                                            destination: FishDetailsView(fish: fish)
                                        ) {
                                            Image(fish.photo)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(
                                                    width: UIScreen.main.bounds.width * 0.35,
                                                    height: UIScreen.main.bounds.width * 0.3
                                                )
                                                .cornerRadius(10)
                                                .clipped()
                                        }
                                    }
                                    
                                    Text("5/30")
                                        .font(Font(Constants.tabFont))
                                        .bold()
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .frame(height: UIScreen.main.bounds.width * 1.05)
                }
            }
            .padding(.top, 100) // same offset as your ScrollView before
            
            // Bottom overlay (unchanged)
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(height: 83)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, 772)
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

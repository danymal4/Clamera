//
//  FishDetailsView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

struct FishDetailsView: View {
    
  
    @ObservedObject var speciesStore: SpeciesStore
    @ObservedObject var aquarium: AquariumFishList
    
    let fishID: UUID

    var body: some View {
      
        if let binding = findFishBinding() {
            let fish = binding.wrappedValue

            ZStack {

            
                WaterView().opacity(0.3)
                IconView()
                    .padding(.top, 55)

                ZStack {
                    Rectangle()
                        .cornerRadius(20)
                        .foregroundStyle(.white)
                        .opacity(0.5)
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.9, 1800),
                            height: min(UIScreen.main.bounds.width * 0.48, 2000)
                        )
                        .padding(.top, 320).shadow(color: .black.opacity(0.1), radius: 10)
                }

                // Add to Aquarium
                HStack {
                    Spacer()

                    Button {
                     
                    } label: {
                        Image("\(fish.speciesName)Icon")
                            .resizable()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.13, 180),
                                height: min(UIScreen.main.bounds.width * 0.13, 180)
                            )
                            .opacity(0.9)
                    }
                    .padding(.top, 305)
                    .padding(.trailing, 45)
                }

                // Remove from Aquarium
                HStack {
                    Spacer()

                    Button {
                     
                    } label: {
                        Image("\(fish.speciesName)Icon")
                            .resizable()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.13, 180),
                                height: min(UIScreen.main.bounds.width * 0.13, 180)
                            )
                            .colorMultiply(.gray)
                            .opacity(0.2)
                    }
                    .padding(.top, 410)
                    .padding(.trailing, 45)
                }

                // Species + Date
                HStack {
                    Text("Species: \(fish.speciesName)")
                        .font(.system(size: UIScreen.main.bounds.width * 0.03))
                        .opacity(0.8)
                        .padding(.top, 550)
                    Spacer()
                }
                .padding().padding()
                
                HStack {
                    Spacer()
                    Text("Caught: \(Text(fish.dateCaught, format: .dateTime.year().month(.wide).day()))")
                        .font(.system(size: UIScreen.main.bounds.width * 0.03))
                        .opacity(0.8)
                        .padding(.top, 550)
                }
                .padding().padding()

                Rectangle()
                    .cornerRadius(45)
                    .foregroundStyle(.blue)
                    .opacity(0.15)
                    .frame(
                        width: min(UIScreen.main.bounds.width * 0.88, 1800),
                        height: min(UIScreen.main.bounds.width * 0.83, 2000)
                    )
                    .padding(.bottom, 250)

                Text("Image Not Found")
                    .font(.custom("", size: 40))
                    .foregroundStyle(.red)
                    .padding(.bottom, 210)

                Image(fishPhoto: fish.photo)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: min(UIScreen.main.bounds.width * 0.85, 1800),
                        height: min(UIScreen.main.bounds.width * 0.8, 2000)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .padding(.bottom, 250)

                // Pin Button
                HStack {
                    Spacer()
                    Button {
                        binding.isPinned.wrappedValue.toggle()
                    } label: {
                        Image(fish.isPinned ? "anchorUnpinned" : "anchor")
                            .resizable()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.08, 180),
                                height: min(UIScreen.main.bounds.width * 0.1, 180)
                            )
                            .foregroundStyle(.white)
                            .opacity(0.9)
                    }
                    .padding(.trailing, 30)
                    .padding(.top, 190)
                }

                VStack {
                    Text("Description")
                        .font(.title2)
                        .bold()
                        .padding(.top, 8)

                    Text(fish.description)
                        .opacity(0.6)

                    Text("Add to Aquarium")
                        .font(.system(size: UIScreen.main.bounds.width * 0.04))
                        .opacity(0.8)
                        .bold()
                        .padding(.bottom)
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.8, 2000),
                            alignment: .leading
                        )
                        .padding()

                    Text("Remove From Aquarium")
                        .font(.system(size: UIScreen.main.bounds.width * 0.04))
                        .opacity(0.8)
                        .bold()
                        .padding(.bottom)
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.8, 2000),
                            alignment: .leading
                        )
                }
                .padding(.top, 300)

                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
                    .padding(.top, 790).shadow(color: .black.opacity(0.1), radius: 10)
            }
            .padding(.top, -10).background(Color.blue.opacity(0.08))

        } else {
            Text("Fish not found")
                .foregroundColor(.red)
                .bold()
        }
    }

   // binding I looked up so structs can actually be modifiable
    private func findFishBinding() -> Binding<Fish>? {
        for speciesIndex in speciesStore.speciesList.indices {
            if let fishIndex = speciesStore.speciesList[speciesIndex]
                .fishList
                .firstIndex(where: { $0.id == fishID }) {
                
                return $speciesStore.speciesList[speciesIndex]
                    .fishList[fishIndex]
            }
        }
        return nil
    }
}

#Preview {
    let store = SpeciesStore()
    let firstFishID = store.speciesList.first?.fishList.first?.id ?? UUID()
    let aquarium = AquariumFishList()
    
    NavigationStack {
        FishDetailsView(speciesStore: store, aquarium: aquarium, fishID: firstFishID)
          
    }
}

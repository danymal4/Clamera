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

    @State private var isEditing = false
    @State private var editedDescription = ""
    @State private var editedWeightString = ""

    var body: some View {
        ZStack {
            WaterView().opacity(0.3)
                .ignoresSafeArea()

            if let binding = findFishBinding() {
                let fish = binding.wrappedValue

                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Species Title Header
                        Text(fish.speciesName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.8), Color.cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.top, 10)

                        // Main Image Card with Pin Overlay
                        ZStack(alignment: .topTrailing) {
                            ZStack(alignment: .bottom) {
                                Image(fishPhoto: fish.photo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .frame(minHeight: 220, maxHeight: 320)
                                    .padding(24)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
                            }

                            // Pin Button Overlay
                            Button {
                                for speciesIndex in speciesStore.speciesList.indices {
                                    for fishIndex in speciesStore.speciesList[speciesIndex].fishList.indices {
                                        speciesStore.speciesList[speciesIndex].fishList[fishIndex].isPinned = false
                                    }
                                }
                                
                                binding.isPinned.wrappedValue.toggle()
                                speciesStore.assignPinnedDisplay()
                                
                                Task {
                                    if let user = AuthManager.shared.user {
                                        await FirestoreManager.shared.saveUser(user: user)
                                    }
                                }
                            } label: {
                                Image(fish.isPinned ? "anchor" : "anchorUnpinned")
                                    .resizable()
                                    .frame(width: 32, height: 40)
                                    .shadow(color: fish.isPinned ? Color.yellow.opacity(0.6) : .clear, radius: 4)
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)

                        // Details & Description Card
                        VStack(alignment: .leading, spacing: 14) {
                            
                            // Catch Date Header
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Caught: \(Text(fish.dateCaught, format: .dateTime.year().month(.wide).day()))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            Divider()

                            // Description Section with Edit Toggle
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Description")
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                    
                                    Button(isEditing ? "Done" : "Edit") {
                                        if isEditing {
                                            binding.description.wrappedValue = editedDescription
                                            if let weight = Double(editedWeightString) {
                                                binding.fishWeight.wrappedValue = Int(weight)
                                            }
                                            
                                            Task {
                                                if let user = AuthManager.shared.user {
                                                    await FirestoreManager.shared.saveUser(user: user)
                                                }
                                            }
                                        } else {
                                            editedDescription = fish.description
                                            editedWeightString = fish.fishWeight != nil ? "\(fish.fishWeight!)" : ""
                                        }
                                        isEditing.toggle()
                                    }
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.cyan)
                                }

                                if isEditing {
                                    VStack(spacing: 10) {
                                        TextField("Description", text: $editedDescription)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        HStack {
                                            Text("Weight (lbs):")
                                                .font(.caption)
                                            TextField("Weight", text: $editedWeightString)
                                                .keyboardType(.decimalPad)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }
                                } else {
                                    Text(fish.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.85))
                                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                        )
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 100)
                    }
                }
            } else {
                Text("Fish not found")
                    .foregroundColor(.red)
                    .bold()
            }
        }
        .background(Color.blue.opacity(0.08).ignoresSafeArea())
    }

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

//
//  CatchManageView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/7/26.
//
import SwiftUI
import PhotosUI

struct CatchManageView: View {
    
    @Binding var editState: EditState
    @State var info = ""
    @State var species = ""
    @State private var weightText: String = ""
    @State private var weight: Int? = nil
    @State private var previewPoints: Int? = nil   // ✅ now stored state
    
    @EnvironmentObject var speciesStore: SpeciesStore
    
    var selectedUIImage: UIImage?
    
    @State private var showSpeciesSuggestions: Bool = false
    
    var speciesSuggestions: [Species] {
        if species.isEmpty { return [] }

        let filtered = speciesStore.speciesList
            .filter { $0.name.lowercased().contains(species.lowercased()) }
            .sorted { $0.name < $1.name }

        var seenNames = Set<String>()
        return filtered.filter { species in
            if seenNames.contains(species.name) {
                return false
            } else {
                seenNames.insert(species.name)
                return true
            }
        }
    }
    
    
    
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            // Top Navigation
            HStack {
                Button("< Cancel") {
                    editState = .notEditing
                }
                .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)
            
            // Photo Hero
            if let uiImage = selectedUIImage {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    
                    
                }
                .padding(.horizontal)
            }
            
            // Input Fields
            VStack(spacing: 15) {
                
                TextField("Description", text: $info)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                
                // Species Field + Dropdown (UNCHANGED STRUCTURE)
                ZStack(alignment: .top) {
                    
                    TextField("Species", text: $species)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .onChange(of: species) { newValue in
                            showSpeciesSuggestions = !newValue.isEmpty
                            
                            guard let index = speciesStore.speciesList.firstIndex(where: {
                                $0.name.lowercased() ==
                                newValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                            }) else {
                                previewPoints = nil
                                return
                            }
                            
                            let fishList = speciesStore.speciesList[index].fishList
                            let fishCount = fishList.count
                            
                            // ✅ Safe previousFishDate
                            let previousFishDate: Date? = fishCount > 0 ? fishList[fishCount - 1].dateCaught : nil
                            
                            let totalOfSpecies = fishCount + 1   // the fish being added
                            let totalOtherFish = max(speciesStore.getFish() - fishCount, 0)
                            
                           // edit this
                            previewPoints =
                                speciesStore.catchOfTheWeek?.name == species
                                ? speciesStore.catchOfTheWeekPoints
                                : speciesStore.calculateClamPoints(
                                    totalOfSpecies: totalOfSpecies,
                                    totalOtherFish: totalOtherFish,
                                    previousFishDate: previousFishDate
                                  )
                        }
                    
                    // Dropdown (UNCHANGED)
                    if showSpeciesSuggestions && !speciesSuggestions.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(speciesSuggestions.prefix(3)) { suggestion in
                                Button(action: {
                                    species = suggestion.name
                                    showSpeciesSuggestions = false
                                }) {
                                    HStack {
                                        Text(suggestion.name)
                                            .foregroundColor(.black)
                                            .padding(.vertical, 10)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .background(Color.white)
                                    .cornerRadius(30)
                                }
                                
                                Divider()
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                                .shadow(radius: 5)
                        )
                        .padding(.top, 40)
                        .zIndex(1)
                    }
                }
                .padding(.horizontal)
                
                
                // ✅ Points Preview (NEW — lightweight, safe)
                if let points = previewPoints {
                    
                    let accentColor = colorForPoints(points)
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(accentColor)
                        
                        Text("+ \(points) Clam Points")
                            .font(.headline)
                            .bold()
                            .foregroundColor(accentColor)
                        
                        Spacer()
                    }
                    .padding()
                    .background(accentColor.opacity(0.15))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.2), value: points)
                }
                
                
                // Weight
                TextField("Weight (optional)                                          lbs", text: $weightText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .onChange(of: weightText) { newValue in
                        if let value = Int(newValue) {
                            weight = value
                        } else {
                            weight = nil
                        }
                    }
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Confirm Button
            Button("Confirm") {
                saveCatch()
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .padding(.horizontal).padding(.vertical)
  
            
            
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        
        
        
    }
    
    func saveCatch() {
        guard let index = speciesStore.speciesList.firstIndex(where: {
            $0.name.lowercased() ==
            species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else {
            print("Species not found")
            return
        }
        
        var photoFilename = ""
        
        if let image = selectedUIImage {
            photoFilename = "\(UUID().uuidString).jpg"
            do {
                try saveImageToDocuments(image: image, key: photoFilename)
            } catch {
                print("Failed to save image: \(error)")
                photoFilename = ""
            }
        }
        
        // Add the fish to the list
        speciesStore.speciesList[index].fishList.append(
            Fish(photo: photoFilename,
                 speciesName: speciesStore.speciesList[index].name,
                 description: info,
                 fishWeight: weight)
        )
        
        // ✅ Calculate points and commit them now
        let fishIndex = speciesStore.speciesList[index].fishList.count
        let previousFishDate: Date? =
            fishIndex > 1
            ? speciesStore.speciesList[index].fishList[fishIndex - 2].dateCaught
            : nil
        
        let totalOfSpecies = fishIndex
        let totalOtherFish = speciesStore.getFish() - 1  // exclude this new fish
     
        
        let points =
            speciesStore.catchOfTheWeek?.name == species
            ? speciesStore.catchOfTheWeekPoints
            : speciesStore.calculateClamPoints(
                totalOfSpecies: totalOfSpecies,
                totalOtherFish: totalOtherFish,
                previousFishDate: previousFishDate
              )

        speciesStore.totalClamPoints += points
        
        // Close editor
        editState = .notEditing
    }
    
    
    func colorForPoints(_ points: Int) -> Color {
        if points >= 90 {
            return Color.purple.opacity(0.8)   // medium purple
        } else if points >= 40 {
            return .blue
        } else if points >= 25 {
            return .orange
        } else if points >= 20 {
            return .gray
        } else {
            return .gray.opacity(0.6)
        }
    }
    
    func saveImageToDocuments(image: UIImage, key: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(key)
        try data.write(to: url)
    }
}

#Preview {
    CatchManageView(
        editState: Binding.constant(.editing),
        selectedUIImage: UIImage(systemName: "photo")
    )
    .environmentObject(SpeciesStore())
}

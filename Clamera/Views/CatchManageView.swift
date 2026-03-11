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
    @State private var previewPoints: Int? = nil
    
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
                .foregroundColor(.cyan)
                Spacer()
            }
            .padding(.horizontal)
            
            // Photo Hero with card style
            if let uiImage = selectedUIImage {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                }
                .padding(.horizontal)
            }
            
            // Input Fields as "cards"
            VStack(spacing: 15) {
                
                TextField("Description", text: $info)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                    )
                    .padding(.horizontal)
                
                // Species Field + Dropdown
                ZStack(alignment: .top) {
                    TextField("Species", text: $species)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                                .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                        )
                        .onChange(of: species) { newValue in
                            showSpeciesSuggestions = !newValue.isEmpty
                            updatePreviewPoints()
                        }
                    
                    // Species Suggestions (kept layout and top padding)
                    if showSpeciesSuggestions && !speciesSuggestions.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(speciesSuggestions.prefix(3).indices, id: \.self) { i in
                                let suggestion = speciesSuggestions[i]
                                
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
                                
                                // Only add divider if not the last
                                if i != speciesSuggestions.prefix(3).count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                                .shadow(radius: 5)
                        )
                        .padding(.top, 40) // necessary
                        .zIndex(1)
                    }
                }
                .padding(.horizontal)
                
                // Points Preview (modern card style)
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
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(accentColor.opacity(0.15))
                            .shadow(color: accentColor.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.2), value: points)
                }
                
                // Weight Field
                TextField("Weight (optional)                                          lbs", text: $weightText)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                    )
                    .onChange(of: weightText) { newValue in
                        weight = Int(newValue)
                    }
                    .padding(.horizontal)
            }
            
            Spacer()
            
            
            // Confirm Button with subtle shadow
            Button("Confirm") {
                saveCatch()
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .padding(.horizontal)
            .padding(.bottom, 40)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helpers
    
    func updatePreviewPoints() {
        guard let index = speciesStore.speciesList.firstIndex(where: {
            $0.name.lowercased() ==
            species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else {
            previewPoints = nil
            return
        }
        let fishList = speciesStore.speciesList[index].fishList
        let fishCount = fishList.count
        let previousFishDate: Date? = fishCount > 0 ? fishList[fishCount - 1].dateCaught : nil
        let totalOfSpecies = fishCount + 1
        let totalOtherFish = max(speciesStore.getFish() - fishCount, 0)
        previewPoints =
            speciesStore.catchOfTheWeek?.name == species
            ? speciesStore.catchOfTheWeekPoints
            : speciesStore.calculateClamPoints(
                totalOfSpecies: totalOfSpecies,
                totalOtherFish: totalOtherFish,
                previousFishDate: previousFishDate
              )
    }
    
    func colorForPoints(_ points: Int) -> Color {
        if points >= 90 { return Color.purple.opacity(0.8) }
        else if points >= 40 { return .blue }
        else if points >= 25 { return .orange }
        else if points >= 20 { return .gray }
        else { return .gray.opacity(0.6) }
    }
    
    func saveCatch() {
        guard let index = speciesStore.speciesList.firstIndex(where: {
            $0.name.lowercased() ==
            species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else { return }
        
        var photoFilename = ""
        if let image = selectedUIImage {
            photoFilename = "\(UUID().uuidString).jpg"
            try? saveImageToDocuments(image: image, key: photoFilename)
        }
        
        speciesStore.speciesList[index].fishList.append(
            Fish(photo: photoFilename,
                 speciesName: speciesStore.speciesList[index].name,
                 description: info,
                 fishWeight: weight)
        )
        
        let fishIndex = speciesStore.speciesList[index].fishList.count
        let previousFishDate: Date? =
            fishIndex > 1 ? speciesStore.speciesList[index].fishList[fishIndex - 2].dateCaught : nil
        
        let totalOfSpecies = fishIndex
        let totalOtherFish = speciesStore.getFish() - 1
        let points =
            speciesStore.catchOfTheWeek?.name == species
            ? speciesStore.catchOfTheWeekPoints
            : speciesStore.calculateClamPoints(
                totalOfSpecies: totalOfSpecies,
                totalOtherFish: totalOtherFish,
                previousFishDate: previousFishDate
              )
        speciesStore.totalClamPoints += points
        editState = .notEditing
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

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
    
    @EnvironmentObject var user: User
    
    var selectedUIImage: UIImage?
    
    @State private var showSpeciesSuggestions: Bool = false
    
    var speciesSuggestions: [Species] {
        if species.isEmpty { return [] }

        let filtered = user.speciesStore.speciesList
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
        ScrollView {
            VStack(spacing: 25) { // increased spacing for breathing room
                
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
                    .padding(.top, 10)
                }
                
                // Input Fields as "cards"
                VStack(spacing: 20) { // more spacing between fields
                    
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
                        
                        // Species Suggestions (keep existing padding/alignment)
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
                            .padding(.top, 40)
                            .zIndex(1)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Points Preview
                    // Points Preview (modern card style)
                    // inside the Points Preview HStack in CatchManageView
                    if let points = previewPoints {
                        let isCatchOfTheWeek = user.speciesStore.catchOfTheWeek?.name == species
                        let accentColor: Color = isCatchOfTheWeek
                            ? Color(red: 1.0, green: 0.84, blue: 0.0) // gold
                            : colorForPoints(points)

                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(accentColor)
                            Text("+ \(points) Clam Points")
                                .font(.headline)
                                .bold()
                                .foregroundColor(accentColor)
                                .shadow(color: isCatchOfTheWeek ? accentColor.opacity(0.6) : .clear, radius: isCatchOfTheWeek ? 6 : 0)
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(accentColor.opacity(isCatchOfTheWeek ? 0.25 : 0.15))
                                .shadow(color: accentColor.opacity(isCatchOfTheWeek ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
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
                
                // Spacer to push Confirm button lower
                Spacer(minLength: 40)
                
                // Confirm Button
                Button("Confirm") {
                    saveCatch()
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .padding(.horizontal)
                .padding(.bottom, 120) // extra space for big tab bar
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helpers
    
    func updatePreviewPoints() {
        guard let index = user.speciesStore.speciesList.firstIndex(where: {
            $0.name.lowercased() ==
            species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else {
            previewPoints = nil
            return
        }
        let fishList = user.speciesStore.speciesList[index].fishList
        let fishCount = fishList.count
        let previousFishDate: Date? = fishCount > 0 ? fishList[fishCount - 1].dateCaught : nil
        let totalOfSpecies = fishCount + 1
        let totalOtherFish = max(user.speciesStore.getFish() - fishCount, 0)
        previewPoints =
        user.speciesStore.catchOfTheWeek?.name == species
        ? user.speciesStore.catchOfTheWeekPoints
        : user.speciesStore.calculateClamPoints(
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
        guard let index = user.speciesStore.speciesList.firstIndex(where: {
            $0.name.lowercased() ==
            species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else { return }
        
        var photoFilename = ""
        if let image = selectedUIImage {
            photoFilename = "\(UUID().uuidString).jpg"
            try? saveImageToDocuments(image: image, key: photoFilename)
        }
        
        // Add the fish to the list
        user.speciesStore.speciesList[index].fishList.append(
            Fish(photo: photoFilename,
                 speciesName: user.speciesStore.speciesList[index].name,
                 description: info,
                 fishWeight: weight)
        )
        
        let fishIndex = user.speciesStore.speciesList[index].fishList.count
        let previousFishDate: Date? =
        fishIndex > 1 ? user.speciesStore.speciesList[index].fishList[fishIndex - 2].dateCaught : nil
        
        let totalOfSpecies = fishIndex
        let totalOtherFish = user.speciesStore.getFish() - 1
        let points =
        user.speciesStore.catchOfTheWeek?.name == species
        ? user.speciesStore.catchOfTheWeekPoints
        : user.speciesStore.calculateClamPoints(
                totalOfSpecies: totalOfSpecies,
                totalOtherFish: totalOtherFish,
                previousFishDate: previousFishDate
              )
        user.speciesStore.totalClamPoints += points
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
    .environmentObject(User())
}

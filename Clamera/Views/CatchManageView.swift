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
    @Binding var selectedUIImage: UIImage?
    @Binding var autoDetectedSpecies: String?
    
    @EnvironmentObject var user: User
    
    @State var info = ""
    @State var species = ""
    @State private var weightText: String = ""
    @State private var weight: Int? = nil
    @State private var previewPoints: Int? = nil
    
    // Step State: 0 = Species, 1 = Description, 2 = Weight
    @State private var currentStep: Int = 0
    @State private var showSpeciesSuggestions: Bool = false
    @State private var isSaving = false
    
    private let maxCardWidth: CGFloat = 500

    private var isDetectingAI: Bool {
        autoDetectedSpecies == nil && species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

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
            VStack(spacing: 20) {
                
                // MARK: - Top Navigation Bar
                HStack {
                    Button(action: {
                        if currentStep > 0 {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentStep -= 1
                            }
                        } else {
                            editState = .notEditing
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(currentStep > 0 ? "Back" : "Cancel")
                        }
                        .font(.headline)
                        .foregroundColor(.cyan)
                    }

                    Spacer()

                    // Step Dots
                    HStack(spacing: 6) {
                        ForEach(0..<3) { step in
                            Capsule()
                                .fill(currentStep == step ? Color.cyan : Color.gray.opacity(0.3))
                                .frame(width: currentStep == step ? 20 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentStep)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // MARK: - Photo Hero Card
                if let uiImage = selectedUIImage {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal, 20)
                }

                // MARK: - Step Container
                VStack(spacing: 16) {
                    if currentStep == 0 {
                        speciesStepView
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                    removal: .move(edge: .leading).combined(with: .opacity)))
                    } else if currentStep == 1 {
                        descriptionStepView
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                    removal: .move(edge: .leading).combined(with: .opacity)))
                    } else {
                        weightStepView
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                    removal: .move(edge: .leading).combined(with: .opacity)))
                    }
                }
                .frame(maxWidth: maxCardWidth)
                .padding(.horizontal, 20)

                // MARK: - Primary Action Button
                VStack(spacing: 10) {
                    Button(action: {
                        if currentStep < 2 {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentStep += 1
                            }
                        } else {
                            Task {
                                await saveCatch()
                            }
                        }
                    }) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(currentStep == 2 ? "Confirm Catch" : "Next")
                                    .bold()
                                if currentStep < 2 {
                                    Image(systemName: "arrow.right")
                                        .font(.subheadline.bold())
                                }
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(canProceed ? Color.cyan : Color.gray.opacity(0.4))
                        .cornerRadius(18)
                        .shadow(color: canProceed ? Color.cyan.opacity(0.3) : .clear, radius: 6, y: 3)
                    }
                    .disabled(!canProceed || isSaving)

                    // Skip button on optional steps
                    if currentStep > 0 {
                        Button("Skip for now") {
                            if currentStep == 1 {
                                withAnimation(.easeInOut(duration: 0.25)) { currentStep = 2 }
                            } else {
                                Task { await saveCatch() }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: maxCardWidth)
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            applyAutoDetectedSpeciesIfAvailable(autoDetectedSpecies)
        }
        .onChange(of: autoDetectedSpecies) { _, newValue in
            applyAutoDetectedSpeciesIfAvailable(newValue)
        }
    }

    private var canProceed: Bool {
        if currentStep == 0 {
            return !species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    private func applyAutoDetectedSpeciesIfAvailable(_ candidate: String?) {
        guard let name = candidate?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        if species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                species = name
                showSpeciesSuggestions = false
                updatePreviewPoints()
            }
        }
    }

    /// True only if this species is this week's target AND it hasn't already
    /// been claimed this week. Being in the album already from a past week
    /// never qualifies on its own — only an actual catch logged during the
    /// active week does.
    private func isEligibleForCatchOfTheWeek(_ speciesName: String) -> Bool {
        guard let cotw = user.speciesStore.catchOfTheWeek, cotw.name == speciesName else { return false }
        return !user.speciesStore.isCatchOfTheWeekClaimed
    }

    // MARK: - Step 1: Species Identification (with AI Loading State)
    private var speciesStepView: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Species Identification")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(isDetectingAI ? "Analyzing photo with Clamera AI..." : "Verify the match or enter name manually.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()

                if isDetectingAI {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Detecting...")
                            .font(.caption.bold())
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.cyan.opacity(0.12))
                    .cornerRadius(12)
                } else if !species.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Identified")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(12)
                }
            }

            ZStack(alignment: .top) {
                HStack(spacing: 12) {
                    Image(systemName: isDetectingAI ? "sparkles" : "magnifyingglass")
                        .foregroundColor(isDetectingAI ? .cyan : .secondary)

                    TextField(isDetectingAI ? "Identifying your fish..." : "Search or enter species", text: $species)
                        .font(.body)
                        .onChange(of: species) { _, newValue in
                            showSpeciesSuggestions = !newValue.isEmpty
                            updatePreviewPoints()
                        }

                    if isDetectingAI {
                        ProgressView()
                            .scaleEffect(0.85)
                    } else if !species.isEmpty {
                        Button {
                            species = ""
                            previewPoints = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)

                // Suggestions Dropdown
                if showSpeciesSuggestions && !speciesSuggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(speciesSuggestions.prefix(3).indices, id: \.self) { i in
                            let suggestion = speciesSuggestions[i]
                            Button {
                                species = suggestion.name
                                showSpeciesSuggestions = false
                                updatePreviewPoints()
                            } label: {
                                HStack {
                                    Text(suggestion.name)
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 12)
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .background(Color(.secondarySystemGroupedBackground))
                            }

                            if i != speciesSuggestions.prefix(3).count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    .padding(.top, 56)
                    .zIndex(2)
                }
            }

            // Points Preview Card with New Species Badge
            if let points = previewPoints {
                let isCatchOfTheWeek = isEligibleForCatchOfTheWeek(species)
                let isFirstCatch = isFirstOfCurrentSpecies()
                let accentColor: Color = isCatchOfTheWeek
                    ? Color(red: 1.0, green: 0.84, blue: 0.0)
                    : colorForPoints(points)

                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: isCatchOfTheWeek ? "crown.fill" : "plus.circle.fill")
                            .foregroundColor(accentColor)
                        Text("+ \(points) Clam Points")
                            .font(.subheadline.bold())
                            .foregroundColor(accentColor)
                        Spacer()
                        if isCatchOfTheWeek {
                            Text("Catch of the Week!")
                                .font(.caption.bold())
                                .foregroundColor(accentColor)
                        } else if isFirstCatch {
                            Text("New Species Bonus!")
                                .font(.caption.bold())
                                .foregroundColor(.purple)
                        }
                    }
                }
                .padding(14)
                .background(accentColor.opacity(0.12))
                .cornerRadius(14)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    // MARK: - Step 2: Description
    private var descriptionStepView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Add a Memory (Optional)")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Where were you fishing? Who were you with?")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            TextField("e.g. Caught on a spinner near the lake pier", text: $info, axis: .vertical)
                .lineLimit(3...6)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        }
    }

    // MARK: - Step 3: Weight & Aquarium Size
    private var weightStepView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Log Weight (Optional)")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Enter the weight to track your personal records.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                TextField("0", text: $weightText)
                    .keyboardType(.numberPad)
                    .font(.title3.bold())
                    .onChange(of: weightText) { _, newValue in
                        weight = Int(newValue.filter { $0.isNumber })
                    }

                Text("lbs")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.cyan)
                    .font(.subheadline)
                    .padding(.top, 2)

                Text("Heavier fish scale up and appear larger when placed in your aquarium.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.cyan.opacity(0.08))
            .cornerRadius(12)
        }
    }

    // MARK: - Calculation Helpers
    private func isFirstOfCurrentSpecies() -> Bool {
        guard let matching = user.speciesStore.speciesList.first(where: {
            $0.name.lowercased() == species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else { return false }
        return matching.fishList.isEmpty
    }

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
        let targetSpeciesName = user.speciesStore.speciesList[index].name
        
        var points = isEligibleForCatchOfTheWeek(targetSpeciesName)
            ? user.speciesStore.catchOfTheWeekPoints
            : user.speciesStore.calculateClamPoints(
                    totalOfSpecies: totalOfSpecies,
                    totalOtherFish: totalOtherFish,
                    previousFishDate: previousFishDate
                  )
        
        if fishCount == 0 {
            points += 50
        }
        
        previewPoints = points
    }
    
    func colorForPoints(_ points: Int) -> Color {
        if points >= 90 { return Color.purple }
        else if points >= 40 { return .blue }
        else if points >= 25 { return .orange }
        else { return .gray }
    }
    
    func saveCatch() async {
        guard let index = user.speciesStore.speciesList.firstIndex(where: {
            $0.name.lowercased() ==
            species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }) else { return }

        isSaving = true

        var photoKey = ""
        if let image = selectedUIImage {
            // 1. Save local document copy for instant rendering without web delay
            photoKey = "\(UUID().uuidString).jpg"
            if let jpegData = image.jpegData(compressionQuality: 0.75),
               let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = docDir.appendingPathComponent(photoKey)
                try? jpegData.write(to: fileURL)
            }
        }
        
        let targetSpeciesName = user.speciesStore.speciesList[index].name
        let isFirstOfSpecies = user.speciesStore.speciesList[index].fishList.isEmpty
        
        user.speciesStore.speciesList[index].fishList.append(
            Fish(photo: photoKey,
                 speciesName: targetSpeciesName,
                 description: info.isEmpty ? "Caught on Clamera" : info,
                 fishWeight: weight)
        )
        
        let fishIndex = user.speciesStore.speciesList[index].fishList.count
        let previousFishDate: Date? =
        fishIndex > 1 ? user.speciesStore.speciesList[index].fishList[fishIndex - 2].dateCaught : nil
        
        let totalOfSpecies = fishIndex
        let totalOtherFish = user.speciesStore.getFish() - 1

        let isCatchOfTheWeek = isEligibleForCatchOfTheWeek(targetSpeciesName)

        var points = isCatchOfTheWeek
        ? user.speciesStore.catchOfTheWeekPoints
        : user.speciesStore.calculateClamPoints(
                totalOfSpecies: totalOfSpecies,
                totalOtherFish: totalOtherFish,
                previousFishDate: previousFishDate
              )
        
        if isFirstOfSpecies {
            points += 50
        }
        
        user.speciesStore.totalClamPoints += points
        user.speciesStore.lastCaughtFishName = targetSpeciesName

        // Persist the claim IMMEDIATELY — not inside the delayed animation
        // closure below — so saveUser() below always captures it correctly.
        if isCatchOfTheWeek {
            user.speciesStore.catchOfTheWeekClaimedWeek = user.speciesStore.currentWeekSeed()
        }

        let animationDuration = 0.2

        withAnimation(.easeInOut(duration: animationDuration)) {
            selectedUIImage = nil
            editState = .notEditing
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            if isCatchOfTheWeek {
                user.speciesStore.popupType = 3
            } else if isFirstOfSpecies {
                user.speciesStore.popupType = 2
            } else {
                user.speciesStore.popupType = 1
            }
        }
        
        let newFish = user.speciesStore.speciesList[index].fishList[fishIndex - 1]
        await FirestoreManager.shared.saveFishCatch(newFish, forUser: user.id)
        await FirestoreManager.shared.saveUser(user: user)
        isSaving = false
    }
}

#Preview {
    CatchManageView(
        editState: Binding.constant(.editing),
        selectedUIImage: Binding.constant(UIImage(systemName: "photo")),
        autoDetectedSpecies: Binding.constant("Largemouth Bass")
    )
    .environmentObject(User())
}

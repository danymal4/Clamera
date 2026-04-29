import SwiftUI

struct CatchManageView: View {
    // These are passed in from CatchView
    @Binding var editState: EditState
    @Binding var selectedUIImage: UIImage?
    var identifiedSpecies: Species?
    
    @EnvironmentObject var user: User
    
    // UI State
    @State private var weightText: String = ""
    @State private var notesText: String = ""
    @State private var speciesText: String = ""
    @State private var isDropdownVisible: Bool = false
    
    // Initializer to set the default text to the AI's result
    init(editState: Binding<EditState>, selectedUIImage: Binding<UIImage?>, identifiedSpecies: Species?) {
        self._editState = editState
        self._selectedUIImage = selectedUIImage
        self.identifiedSpecies = identifiedSpecies
        // If AI found something, pre-fill the text box
        self._speciesText = State(initialValue: identifiedSpecies?.name ?? "")
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // 1. HEADER
                    VStack(spacing: 8) {
                        Text("New Catch")
                            .font(.system(size: 34, weight: .bold))
                    }
                    .padding(.top, 20)

                    // 2. IMAGE PREVIEW
                    if let uiImage = selectedUIImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 10)
                    }

                    // 3. INPUT FIELDS
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Manual Species Input with Dropdown
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Species")
                                .font(.caption).bold().foregroundColor(.gray)
                            
                            TextField("Search species...", text: $speciesText, onEditingChanged: { isEditing in
                                isDropdownVisible = isEditing
                            })
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .autocorrectionDisabled()
                            
                            if isDropdownVisible {
                                let filtered = user.speciesStore.speciesList.filter {
                                    $0.name.lowercased().contains(speciesText.lowercased())
                                }
                                
                                if !filtered.isEmpty {
                                    VStack(alignment: .leading) {
                                        ForEach(filtered.prefix(5), id: \.self) { species in
                                            Button {
                                                speciesText = species.name
                                                isDropdownVisible = false
                                                hideKeyboard()
                                            } label: {
                                                HStack {
                                                    Text(species.name)
                                                    Spacer()
                                                }
                                                .padding(.vertical, 8)
                                                .padding(.horizontal)
                                            }
                                            Divider()
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        
                        // Weight Input
                        VStack(alignment: .leading) {
                            Text("Weight (lbs)")
                                .font(.caption).bold().foregroundColor(.gray)
                            TextField("0", text: $weightText)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }

                        // Notes Input
                        VStack(alignment: .leading) {
                            Text("Notes")
                                .font(.caption).bold().foregroundColor(.gray)
                            TextEditor(text: $notesText)
                                .frame(height: 100)
                                .padding(4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 30)

                    // 4. SAVE BUTTON
                    Button {
                        saveCatch()
                    } label: {
                        Text("Confirm Catch")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(isValidSpecies ? Color.cyan : Color.gray)
                            .cornerRadius(20)
                            .padding(.horizontal, 30)
                    }
                    .disabled(!isValidSpecies)

                    Button("Cancel") {
                        editState = .notEditing
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Logic
    
    private var isValidSpecies: Bool {
        user.speciesStore.speciesList.contains(where: { $0.name.lowercased() == speciesText.lowercased() })
    }
    
    func saveCatch() {
        // Find the species object matching the text (either AI found it or user typed it)
        guard let species = user.speciesStore.speciesList.first(where: { $0.name.lowercased() == speciesText.lowercased() }) else { return }
        
        let newFish = Fish(
            photo: "",
            speciesName: species.name,
            description: notesText,
            fishWeight: Int(weightText)
        )
        
        let earnedPoints = user.speciesStore.calculateClamPoints(
            totalOfSpecies: species.fishList.count + 1,
            totalOtherFish: user.speciesStore.getFish()
        )
        
        user.speciesStore.totalClamPoints += earnedPoints
        species.fishList.append(newFish)
        user.speciesStore.refresh()
        editState = .notEditing
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    let mockSpecies = Species(name: "Common Carp", imageName: "")
    let mockUser = User()
    mockUser.speciesStore.speciesList = [mockSpecies]
    
    return CatchManageView(
        editState: .constant(.editing),
        selectedUIImage: .constant(UIImage(systemName: "fish.fill")),
        identifiedSpecies: mockSpecies
    )
    .environmentObject(mockUser)
}

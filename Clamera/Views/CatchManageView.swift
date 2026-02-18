//
//  CatchManageView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/7/26.
//

import SwiftUI
import PhotosUI

// fancy blur
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


struct CatchManageView: View {
    
    @Binding var editState: EditState
    @State var info = ""
    @State var species = ""
    @EnvironmentObject var speciesStore: SpeciesStore
    
    // image from Catch
    var selectedUIImage: UIImage?
    
    
    @State private var showSpeciesSuggestions: Bool = false
    
    var speciesSuggestions: [Species] {
        if species.isEmpty { return [] }
        return speciesStore.speciesList
            .filter { $0.name.lowercased().contains(species.lowercased()) }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background water and blur
            WaterView().offset(y: -300)
            WaterView().offset(y: -700)
            WaterView().offset(y: 200)
            WaterView().offset(y: 300)
            WaterView().offset(y: 300)
            
            BlurView(style: .systemUltraThinMaterial)
                .ignoresSafeArea()
            
            Image("fishies").resizable().opacity(0.03)
            
         
            HStack {
                Button { editState = .notEditing } label: { Text("< cancel") }
                Spacer()
            }
            .padding(.bottom, 730)
            .padding()
            
            IconView().padding(.top, 25)
            
            
       
            Rectangle()
                .cornerRadius(40)
                .foregroundStyle(.white)
                .opacity(0.3)
                .frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                       height: min(UIScreen.main.bounds.width * 0.8, 5000)).padding(.top, 250)
            
            Rectangle()
                .cornerRadius(30)
                .foregroundStyle(.white)
                .opacity(0.4)
                .frame(width: min(UIScreen.main.bounds.width * 0.75, 2000),
                       height: min(UIScreen.main.bounds.width * 0.75, 5000)).padding(.top, 260)
            
         // dropdown logic
                if showSpeciesSuggestions && !speciesSuggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(speciesSuggestions.prefix(8)) { suggestion in
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
                    .padding(.horizontal, 50)
                    .padding(.top, 460)
                    .zIndex(1)
                }
                
            
            
            

            VStack {
                Text("Description")
                    .font(.system(size: UIScreen.main.bounds.width * 0.05))
                    .bold()
                    .opacity(0.9)
                
                TextField("Enter text", text: $info)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 55)
                    .foregroundStyle(.blue)
                    .textInputAutocapitalization(.never)
                
                Text("Species")
                    .font(.system(size: UIScreen.main.bounds.width * 0.05))
                    .padding(.top, 46)
                    .bold()
                    .opacity(0.9)
                
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        TextField("Enter text", text: $species)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 55)
                            .padding(.bottom, 35)
                            .foregroundStyle(.blue)
                            .textInputAutocapitalization(.never)
                            .onChange(of: species) { newValue in
                                showSpeciesSuggestions = !newValue.isEmpty
                            }
                        
                      
                        
                    }
                }
                
                HStack {
                    Spacer()
                    Button("Confirm") {
                        guard let index = speciesStore.speciesList.firstIndex(where: {
                            $0.name.lowercased() == species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        }) else {
                            print("Species not found")
                            return
                        }
                        
                        var photoFilename = ""
                        
                        if let image = selectedUIImage {
                           
                            // file name storage (chat)
                            
                            photoFilename = "\(UUID().uuidString).jpg"
                            do {
                                try saveImageToDocuments(image: image, key: photoFilename)
                            } catch {
                                print("Failed to save image: \(error)")
                                photoFilename = ""
                            }
                        }
                        
                        // adding back to speciesStore
                        speciesStore.speciesList[index].fishList.append(
                            Fish(
                                photo: photoFilename,
                                speciesName: speciesStore.speciesList[index].name,
                                description: info
                            )
                        )
                        
                        editState = .notEditing
                    }
                    .padding(.horizontal, 67)
                    .buttonStyle(.borderedProminent)
                    .opacity(0.9)
                }
            }
            .padding(.top, 290)
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        
        ZStack(alignment: .top) {
            
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

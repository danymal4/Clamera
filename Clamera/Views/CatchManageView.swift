//
//  CatchManageView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/7/26.
//

import SwiftUI
import PhotosUI

// MARK: - BlurView
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - CatchManageView
struct CatchManageView: View {
    
    @Binding var editState: EditState
    @State var info = ""
    @State var species = ""
    @EnvironmentObject var speciesStore: SpeciesStore
    
    // Receive the UIImage from CatchView
    var selectedUIImage: UIImage?
    
    var body: some View {
        ZStack {
            // Background water and blur
            WaterView().offset(y: -300)
            WaterView().offset(y: -700)
            WaterView().offset(y: 200)
            WaterView().offset(y: 300)
            WaterView().offset(y: 300)
            
            BlurView(style: .systemUltraThinMaterial)
                .ignoresSafeArea()
            
            Image("fishies").resizable().opacity(0.03)
            
            // Cancel button
            HStack {
                Button { editState = .notEditing } label: { Text("< cancel") }
                Spacer()
            }
            .padding(.bottom, 730)
            .padding()
            
            IconView().padding(.top, 25)
            
            // Decorative rectangles
            Rectangle()
                .cornerRadius(40)
                .foregroundStyle(.white)
                .opacity(0.3)
                .frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                       height: min(UIScreen.main.bounds.width * 0.8, 5000))
            
            Rectangle()
                .cornerRadius(30)
                .foregroundStyle(.white)
                .opacity(0.4)
                .frame(width: min(UIScreen.main.bounds.width * 0.75, 2000),
                       height: min(UIScreen.main.bounds.width * 0.75, 5000))
            
            // Input fields and confirm button
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
                
                TextField("Enter text", text: $species)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 55)
                    .padding(.bottom, 35)
                    .foregroundStyle(.blue)
                    .textInputAutocapitalization(.never)
                
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
                        
                        // If the user provided a UIImage, save it
                        if let image = selectedUIImage {
                            // Generate a unique filename
                            photoFilename = "\(UUID().uuidString).jpg"
                            do {
                                try saveImageToDocuments(image: image, key: photoFilename)
                            } catch {
                                print("Failed to save image: \(error)")
                                photoFilename = "" // fallback
                            }
                        }

                        // Append new Fish with the saved photo string
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
            .padding(.top, 30)
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func saveImageToDocuments(image: UIImage, key: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(key) // <-- remove ".jpg" here
        try data.write(to: url)
    }

    
}
    #Preview {
        // Pass a sample UIImage to preview
        CatchManageView(
            editState: Binding.constant(.editing),
            selectedUIImage: UIImage(systemName: "photo") // example placeholder image
        )
   
    }

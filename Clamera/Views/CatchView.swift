//
//  CatchView.swift
//  Clamera
//
//  Created by Dany Malaeb on 1/28/26.
//
import SwiftUI
import PhotosUI

struct CatchView: View {
    
    @EnvironmentObject var user: User
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State var editState: EditState = .notEditing
    @State private var detectedSpecies: String?
    @State private var isDetectingSpecies = false
    @State private var detectionMessage: String?
    @State private var detectionTask: Task<Void, Never>?
    @State private var lastDetectedImageFingerprint: String?
    
    // States for the photo choice menu and camera picker
    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    
    var body: some View {
        NavigationStack {
            if editState == .notEditing {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            
                            HStack(alignment: .center, spacing: 4) {
                                Image("Rod")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .opacity(0.85)
                                
                                Text("Catch")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.black.opacity(0.85),
                                                Color.cyan.opacity(0.7)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            
                            // MARK: - Central Interactive Drop Zone
                            Button {
                                showActionSheet = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(
                                            selectedImage == nil
                                            ? AnyShapeStyle(
                                                LinearGradient(
                                                    colors: [Color.cyan.opacity(0.08), Color.blue.opacity(0.12)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            : AnyShapeStyle(Color.clear)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 28)
                                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1.5)
                                        )
                                        .frame(height: 260)
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    
                                    if let image = selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 260)
                                            .clipShape(RoundedRectangle(cornerRadius: 28))
                                            .overlay(
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Spacer()
                                                        Label("Tap to change", systemImage: "photo.badge.arrow.down")
                                                            .font(.caption2)
                                                            .bold()
                                                            .padding(.horizontal, 10)
                                                            .padding(.vertical, 5)
                                                            .background(.ultraThinMaterial)
                                                            .clipShape(Capsule())
                                                            .padding(12)
                                                    }
                                                }
                                            )
                                    } else {
                                        VStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.cyan.opacity(0.15))
                                                    .frame(width: 64, height: 64)
                                                
                                                Image(systemName: "plus")
                                                    .font(.system(size: 26, weight: .bold))
                                                    .foregroundColor(.cyan)
                                            }
                                            
                                            VStack(spacing: 4) {
                                                Text("Tap to add catch photo")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                Text("Take photo or choose from album")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            .confirmationDialog("Add Catch Photo", isPresented: $showActionSheet, titleVisibility: .visible) {
                                Button("Take Photo", systemImage: "camera") {
                                    showCamera = true
                                }
                                Button("Choose from Album", systemImage: "photo.on.rectangle") {
                                    showPhotoPicker = true
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
                            .onChange(of: selectedItem) { _, newItem in
                                guard let newItem else { return }
                                detectionTask?.cancel()
                                detectionTask = Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
                                        detectedSpecies = nil
                                        detectionMessage = nil
                                        await detectFishSpeciesIfNeeded(from: uiImage)
                                    }
                                }
                            }
                            .sheet(isPresented: $showCamera) {
                                ImagePicker(selectedImage: $selectedImage) { image in
                                    if let image = image {
                                        detectedSpecies = nil
                                        detectionMessage = nil
                                        Task {
                                            await detectFishSpeciesIfNeeded(from: image)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - AI Detection Status / Feedback
                            Group {
                                if isDetectingSpecies {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text("Analyzing fish species...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                } else if let detectedSpecies {
                                    Label("Detected: \(detectedSpecies)", systemImage: "checkmark.circle.fill")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.green)
                                } else if let detectionMessage {
                                    Text(detectionMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // MARK: - Proceed Button
                            if selectedImage != nil {
                                Button {
                                    editState = .editing
                                } label: {
                                    HStack {
                                        Text("Continue to Details")
                                            .font(.headline)
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .cyan.opacity(0.3), radius: 6, x: 0, y: 3)
                                }
                                .padding(.horizontal, 20)
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // MARK: - Recently Caught Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recently Caught")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        let allCaughtFish = user.speciesStore.speciesList.flatMap { $0.fishList }
                                        
                                        if allCaughtFish.isEmpty {
                                            Text("No catches yet. Add your first fish above!")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                        } else {
                                            ForEach(allCaughtFish.sorted(by: { $0.dateCaught > $1.dateCaught })) { fish in
                                                NavigationLink(destination: FishDetailsView(speciesStore: user.speciesStore, aquarium: user.aquarium, fishID: fish.id)) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Image(fishPhoto: fish.photo)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 70, height: 70)
                                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                                            .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
                                                        
                                                        Text(fish.speciesName)
                                                            .font(.caption2.bold())
                                                            .foregroundColor(.primary)
                                                            .lineLimit(1)
                                                            .frame(width: 70, alignment: .leading)
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 4)
                            
                            Spacer(minLength: 30)
                        }
                    }
                }
            } else {
                CatchManageView(
                    editState: $editState,
                    selectedUIImage: $selectedImage,
                    autoDetectedSpecies: $detectedSpecies
                )
            }
        }
    }

    private func detectFishSpeciesIfNeeded(from image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            detectionMessage = "Could not read selected image."
            return
        }

        let fingerprint = imageFingerprint(for: imageData)
        if lastDetectedImageFingerprint == fingerprint, detectedSpecies != nil {
            detectionMessage = nil
            return
        }
        lastDetectedImageFingerprint = fingerprint
        await detectFishSpecies(from: image)
    }

    private func detectFishSpecies(from image: UIImage) async {
        if isDetectingSpecies { return }
        isDetectingSpecies = true
        defer { isDetectingSpecies = false }

        let speciesNames = user.speciesStore.speciesList.map { $0.name }

        do {
            let prediction = try await GeminiFishVisionService.shared.detectFishName(from: image, speciesList: speciesNames)
            print("🤖 Raw Gemini Vision Prediction: '\(prediction)'")
            
            let matchedName = user.speciesStore.bestMatchingSpeciesName(for: prediction)
            print("🎯 Matched Species Name: '\(matchedName ?? "nil")'")
            
            await MainActor.run {
                if let matchedName {
                    detectedSpecies = matchedName
                    detectionMessage = nil
                } else {
                    detectedSpecies = nil
                    detectionMessage = "Couldn't confidently identify the species."
                }
            }
        } catch {
            print("❌ Gemini detection error: \(error.localizedDescription)")
            await MainActor.run {
                detectedSpecies = nil
                detectionMessage = "Detection failed: \(error.localizedDescription)"
            }
        }
    }

    private func imageFingerprint(for data: Data) -> String {
        let prefixSum = data.prefix(64).reduce(0) { partialResult, byte in
            partialResult + Int(byte)
        }
        return "\(data.count)-\(prefixSum)"
    }
}

// Crash-proof camera representable with simulator fallback
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage?) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    CatchView()
        .environmentObject(User())
}

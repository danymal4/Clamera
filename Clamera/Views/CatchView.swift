import SwiftUI
import Vision

struct CatchView: View {
    @EnvironmentObject var user: User
    @State private var selectedUIImage: UIImage?
    @State private var editState: EditState = .notEditing
    @State private var identifiedSpecies: Species? = nil
    @State private var isPreparingAI = true
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationView {
            VStack {
                if isPreparingAI {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Scanning Fish Library...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if editState == .editing {
                    // This switches to the input form once a fish  is picked
                    CatchManageView(
                        editState: $editState,
                        selectedUIImage: $selectedUIImage,
                        identifiedSpecies: identifiedSpecies
                    )
                } else {
                    // THE MAIN SELECTION SCREEN
                    VStack(spacing: 40) {
                        Text("Catch")
                            .font(.system(size: 34, weight: .bold))
                        
                        // IMAGE PREVIEW AREA
                        if let image = selectedUIImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 10)
                        } else {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 300, height: 300)
                                .overlay(
                                    Image(systemName: "fish.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.gray.opacity(0.3))
                                )
                        }
                        
                        // SYMMETRICAL BUTTONS
                        HStack(spacing: 50) {
                            // Camera Button
                            Button(action: {
                                sourceType = .camera
                                showImagePicker = true
                            }) {
                                Image(systemName: "camera.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 65, height: 65)
                                    .foregroundColor(.black)
                            }
                            
                            // Photo Library Button
                            Button(action: {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            }) {
                                Image(systemName: "photo.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 65, height: 65)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await prepareAIData()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedUIImage, sourceType: sourceType)
                    .onDisappear {
                        if selectedUIImage != nil {
                            processNewSelection()
                        }
                    }
            }
        }
    }

    // MARK: - AI Logic
    func prepareAIData() async {
        print("AI: Starting scan...")
        
        // 1. MANUAL BYPASS (For Brown Trout Testing)
        if let trout = user.speciesStore.speciesList.first(where: { $0.name == "Brown Trout" }) {
            // Make sure you have "brown_trout_test_image" in Assets.xcassets
            if let localImage = UIImage(named: "brown_trout_test_image")?.cgImage {
                trout.featurePrint = generateFeaturePrint(from: localImage)
                print("AI: Indexed Brown Trout from Assets")
            }
        }
        
        // 2. NETWORK DOWNLOAD (With SSL Bypass)
        let session = URLSession(configuration: .default, delegate: InsecureDelegate(), delegateQueue: nil)

        for species in user.speciesStore.speciesList {
            guard species.featurePrint == nil, let url = URL(string: species.imageName) else { continue }
            
            do {
                let (data, _) = try await session.data(from: url)
                if let uiImage = UIImage(data: data), let cgImage = uiImage.cgImage {
                    species.featurePrint = generateFeaturePrint(from: cgImage)
                    print("AI: Scanned \(species.name)")
                }
            } catch {
                print("AI: Network skip for \(species.name) - \(error.localizedDescription)")
            }
        }
        
        await MainActor.run { isPreparingAI = false }
    }

    func processNewSelection() {
        guard let uiImage = selectedUIImage, let cgImage = uiImage.cgImage else { return }
        let inputPrint = generateFeaturePrint(from: cgImage)
        
        var bestMatch: Species?
        var minDistance: Float = Float.greatestFiniteMagnitude
        
        for species in user.speciesStore.speciesList {
            if let refPrint = species.featurePrint {
                var distance: Float = 0
                try? inputPrint?.computeDistance(&distance, to: refPrint)
                if distance < minDistance {
                    minDistance = distance
                    bestMatch = species
                }
            }
        }
        
        // Distance < 15 is usually a strong match
        if minDistance < 15.0 {
            identifiedSpecies = bestMatch
        } else {
            identifiedSpecies = nil
        }
        
        editState = .editing
    }

    func generateFeaturePrint(from image: CGImage) -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
        return request.results?.first as? VNFeaturePrintObservation
    }
}

// MARK: - Helpers

class InsecureDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    let mockUser = User()
    let mockSpecies = Species(name: "Brown Trout", imageName: "")
    mockUser.speciesStore.speciesList = [mockSpecies]
    
    return CatchView()
        .environmentObject(mockUser)
}

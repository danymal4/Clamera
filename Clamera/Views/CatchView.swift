//
//  CatchView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
import SwiftUI
import PhotosUI



struct CatchView: View {
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State var editState: EditState = .notEditing
    
    let baseWidth: CGFloat = 403
    let baseHeight: CGFloat = 844
    
    var hScale: CGFloat { min(UIScreen.main.bounds.width / baseWidth, 1.2) }
    var vScale: CGFloat { min(UIScreen.main.bounds.height / baseHeight, 1.2) }
    
    var body: some View {
        if editState == .notEditing {
            ZStack {
                // Main background white
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 20 * vScale) {
                    
                    // Header with fishing rod and title
                    HStack(alignment: .top, spacing: -35) {
                        Image("Rod")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.18,
                                   height: UIScreen.main.bounds.width * 0.18)
                            .opacity(0.9).padding(.top, -16)
                        
                        Text("Catch")
                            .font(.custom("AkayaTelivigala-regular", size: UIScreen.main.bounds.width * 0.22))
                            .foregroundColor(.blue)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 2)
                            .rotationEffect(.degrees(3))
                    }
                    .padding(.top, 10)
                    
                    // Image container
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(selectedImage == nil ? Color(.systemGray4) : Color.white.opacity(0.3))
                            .frame(width: min(UIScreen.main.bounds.width * 0.85, 750),
                                   height: min(UIScreen.main.bounds.width * 0.8, 750))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: min(UIScreen.main.bounds.width * 0.85, 750),
                                       height: min(UIScreen.main.bounds.width * 0.8, 750))
                                .clipped()
                                .cornerRadius(40)
                        } else {
                            HStack(spacing: 20 * hScale) {
                                Text("Fish image")
                                    .font(.custom("HelveticaNeue-Thin", size: 18))
                                    .bold()
                                    .foregroundColor(.gray)
                                Image("FishIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(width: min(UIScreen.main.bounds.width * 0.25, 120),
                                           height: min(UIScreen.main.bounds.width * 0.25, 120))
                            }
                        }
                    }
                    
                    // Buttons – original positions, slightly smaller
                    HStack(alignment: .center, spacing: 20 * hScale) {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack(spacing: 4) {
                                Image("CameraIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(width: min(UIScreen.main.bounds.width * 0.25, 160),
                                           height: min(UIScreen.main.bounds.width * 0.28, 140))
                                    .opacity(0.85)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                                Text("Add Photo")
                                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                    .foregroundColor(.black.opacity(0.9))
                                    .bold()
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            guard let newItem else { return }
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                        .offset(y: -10 * vScale)
                        
                        Button {
                            if selectedImage != nil {
                                editState = .editing
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image("uploadIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: min(UIScreen.main.bounds.width * 0.35, 180),
                                           height: min(UIScreen.main.bounds.width * 0.35, 180))
                                    .opacity(selectedImage == nil ? 0.7 : 0.9)
                                    .shadow(color: .black.opacity(selectedImage == nil ? 0.0 : 0.1), radius: 5)
                                
                                Text("Upload")
                                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                    .foregroundColor(.black.opacity(selectedImage == nil ? 0.5 : 0.9))
                                    .bold()
                                    .offset(y: -33 * vScale)
                            }
                        }
                        .offset(y: 10 * vScale)
                        .disabled(selectedImage == nil)
                    }
                    .offset(y: -20 * vScale)
                    .offset(x: 10 * vScale)
                    
                } // VStack
                .padding(.top, 30 * vScale)
                
                // Optional accent gradient behind header
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                .cornerRadius(100)
                .rotationEffect(.degrees(10))
                .offset(y: -100)
                .blendMode(.overlay)
                
            } // ZStack
        } else {
            CatchManageView(editState: $editState, selectedUIImage: selectedImage)
        }
    }
}

#Preview {
    CatchView()
}

#Preview {
    CatchView()
}

#Preview {
    CatchView()
}


#Preview {
    CatchView()
}

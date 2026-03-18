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
                Color.white
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20 * vScale) {
                        
                       
                        HStack(alignment: .top, spacing: -20) {
                            Image("Rod")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width * 0.14,
                                       height: UIScreen.main.bounds.width * 0.14)
                                .opacity(0.45)
                                .padding(.top, -33)
                            
                            Text("Catch")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.black)
                                .shadow(color: .black.opacity(0.08), radius: 2, x: 1, y: 1)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 30)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Image container
                        ZStack {
                            RoundedRectangle(cornerRadius: 40)
                                .fill(
                                    selectedImage == nil
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.08), Color.gray.opacity(0.18)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                      )
                                    : AnyShapeStyle(Color.white.opacity(0.3))
                                )
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.85, 750),
                                    height: min(UIScreen.main.bounds.width * 0.85, 750)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: min(UIScreen.main.bounds.width * 0.85, 750),
                                           height: min(UIScreen.main.bounds.width * 0.85, 750))
                                    .clipped()
                                    .cornerRadius(40)
                                    .shadow(color: .cyan.opacity(0.15), radius: 15, x: 0, y: 0)
                            } else {
                                HStack(spacing: 20 * hScale) {
                                    Text("Fish image")
                                        .font(.system(size: 18, weight: .semibold))
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
                        .padding(.top, 10 * vScale)     // added breathing room
                        .padding(.bottom, 8)           // subtle separation from buttons
                        
                        // Buttons
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
                                        .font(.system(size: UIScreen.main.bounds.width * 0.04, weight: .semibold))
                                        .foregroundColor(.cyan)
                                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
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
                                        .font(.system(size: UIScreen.main.bounds.width * 0.04, weight: .semibold))
                                        .foregroundColor(selectedImage == nil ? .gray.opacity(0.7) : .cyan)
                                        .offset(y: -33 * vScale)
                                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                                }
                            }
                            .offset(y: 10 * vScale)
                            .disabled(selectedImage == nil)
                        }
                        .offset(y: -10 * vScale)   // reduced from -20
                        .offset(x: 10 * vScale)
                        
                        // Recently Caught
                        VStack(spacing: 10) {
                            
                            HStack {
                                Spacer()
                                Text("Recently Caught")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<10) { _ in
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.15)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                                    }
                                }
                                .padding(12)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                                    .opacity(0.0)
                            )
                        }
                        .padding(.top, -5)   // removed negative padding
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 25)

                        Spacer(minLength: 70)   // increased bottom breathing room
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50 * vScale)
                    .padding(.bottom, 50)
                }
                .background(Color.blue.opacity(0.01))
                
                LinearGradient(
                    colors: [Color.black.opacity(0.03), Color.black.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                .cornerRadius(100)
                .rotationEffect(.degrees(10))
                .offset(y: -100)
                .blendMode(.overlay)
                
            }
        } else {
            CatchManageView(editState: $editState, selectedUIImage: selectedImage)
        }
    }
}
#Preview {
    CatchView()
}

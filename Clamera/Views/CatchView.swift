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
                WaterView().offset(y: -265 * vScale)
                IconView()
                
                VStack(spacing: 20 * vScale) {
                
                    Text("Catch")
                        .font(.custom("IslandMoments-Regular", size: UIScreen.main.bounds.width * 0.2))
                        .opacity(0.9)
                        .foregroundStyle(.blue).padding(.bottom, -10)
                    
                    ZStack {
                       
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(
                                width: UIScreen.main.bounds.width * 0.88,
                                height: UIScreen.main.bounds.width * 0.83
                            )
                            .cornerRadius(15)
                        
                        Rectangle()
                            .frame(width: min(UIScreen.main.bounds.width * 0.85, 750),
                                   height: min(UIScreen.main.bounds.width * 0.8, 750))
                            .foregroundStyle(Color.gray.opacity(0.4))
                            .compositingGroup()
                            .cornerRadius(10)
                        
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: min(UIScreen.main.bounds.width * 0.85, 750),
                                       height: min(UIScreen.main.bounds.width * 0.8, 750))
                                .cornerRadius(10)
                        } else {
                            HStack(spacing: 20 * hScale) {
                                Text("Fish image")
                                    .font(.custom("HelveticaNeue-Thin", size: 20))
                                    .bold()
                                Image("FishIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(width: min(UIScreen.main.bounds.width * 0.3, 160),
                                           height: min(UIScreen.main.bounds.width * 0.3, 160))
                            }
                        }
                  
                        
                        
                        
                    }
                    
                    
         
                    
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
                                    .frame(width: min(UIScreen.main.bounds.width * 0.32, 220),
                                           height: min(UIScreen.main.bounds.width * 0.37, 160))
                                    .opacity(0.9)
                                Text("Add Photo") .font(.system(size: UIScreen.main.bounds.width * 0.05))
                                    .foregroundStyle(.black.opacity(0.7)).bold()
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
                        }.offset(y: -10 * vScale)
                        
                        Button {
                            if let image = selectedImage {
                                editState = .editing
                            }
                        } label: {
                          
                            VStack(spacing: 4) {
                                Image("uploadIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(
                                        width: min(UIScreen.main.bounds.width * 0.46, 220),
                                        height: min(UIScreen.main.bounds.width * 0.46, 220)
                                    )
                                    .colorMultiply(selectedImage == nil ? Color(.systemGray4) : .white)
                                
                                    .opacity(selectedImage == nil ? 0.6 : 1.0)
                             
                                Text("Upload") .font(.system(size: UIScreen.main.bounds.width * 0.05))
                                    .foregroundStyle(.black.opacity(0.7)).offset(y: -42 * vScale).bold()
                            }
                        }
                        .offset(y: 15 * vScale)
                    }
                    .offset(y: -20 * vScale)
                    .offset(x: 10 * vScale)
                }
                .padding(.top, 135 * vScale)
                
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(height: 83)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        } else {
            // Pass the selected UIImage to CatchManageView
            CatchManageView(editState: $editState, selectedUIImage: selectedImage)
       
        }
    }
}

// MARK: - Preview
#Preview {
    CatchView()
}

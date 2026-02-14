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
                WaterView().offset(y: -375 * vScale)
                IconView()
                
                VStack(spacing: 20 * vScale) {
                    ZStack {
                        Rectangle()
                            .frame(width: min(UIScreen.main.bounds.width * 0.8, 750),
                                   height: min(UIScreen.main.bounds.width * 1.2, 750))
                            .foregroundStyle(Color.gray.opacity(0.4))
                            .compositingGroup()
                            .cornerRadius(20)
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: min(UIScreen.main.bounds.width * 0.8, 750),
                                       height: min(UIScreen.main.bounds.width * 1.2, 750))
                                .cornerRadius(20)
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
                            Image("CameraIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: min(UIScreen.main.bounds.width * 0.25, 220),
                                       height: min(UIScreen.main.bounds.width * 0.3, 160))
                                .opacity(0.9)
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
                        
                        Button {
                            if let image = selectedImage {
                                editState = .editing
                            }
                        } label: {
                            Image("uploadIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: min(UIScreen.main.bounds.width * 0.36, 220),
                                       height: min(UIScreen.main.bounds.width * 0.36, 220))
                        }
                        .offset(y: 20 * vScale)
                    }
                    .offset(y: -20 * vScale)
                    .offset(x: 10 * vScale)
                }
                .padding(.top, 80 * vScale)
                
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

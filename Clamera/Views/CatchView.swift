//
//  CatchView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct CatchView: View {

    @State var editState: EditState = .notEditing


    let baseWidth: CGFloat = 403
    let baseHeight: CGFloat = 844

    var hScale: CGFloat { min(UIScreen.main.bounds.width / baseWidth, 1.2) }
    var vScale: CGFloat { min(UIScreen.main.bounds.height / baseHeight, 1.2) }

    var body: some View {

        if editState == .notEditing {

            ZStack {

     
                WaterView()
                    .offset(y: -375 * vScale)

             
                IconView()
                    

                
                VStack(spacing: 20 * vScale) {

            
                    ZStack {
                        Rectangle()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.8, 750), // slightly bigger
                                height: min(UIScreen.main.bounds.width * 1.2, 750) // slightly bigger
                            )
                            .foregroundStyle(Color.gray.opacity(0.4))
                            .compositingGroup()
                            .cornerRadius(20)

                        HStack(spacing: 20 * hScale) {
                            Text("Fish image")
                                .font(.custom("HelveticaNeue-Thin", size: 20))
                                .bold()

                            Image("FishIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.3, 160), // slightly bigger
                                    height: min(UIScreen.main.bounds.width * 0.3, 160) // slightly bigger
                                )
                        }
                    }

         
                    HStack(alignment: .center, spacing: 20 * hScale) {

                        Button {
                            
                        }
                        
                        label: {
                            Image("CameraIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.25, 220), // slightly bigger
                                    height: min(UIScreen.main.bounds.width * 0.3, 160) // slightly bigger
                                )
                                .opacity(0.9)
                        }
                        Button {
                            editState = .editing
                        } label: {
                            Image("uploadIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.36, 220), // slightly bigger
                                    height: min(UIScreen.main.bounds.width * 0.36, 220) // slightly bigger
                                )
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
            CatchManageView(editState: $editState)
        }
    }
}

#Preview {
    CatchView()
}


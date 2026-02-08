//
//  AquariumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

enum EditState {
    case editing, notEditing
}

struct AquariumView: View {

    @State var editState: EditState = .notEditing
    @State var clean: Double = 0.3
    @State var speed: Double = 0
    @State var scale: Double = 0

    var body: some View {

        if editState == .notEditing {

            ZStack {

                IconView().padding(.horizontal, 15)

                VStack {
                    Text("Aquarium")
                        .font(.custom(
                            "IslandMoments-Regular",
                            size: UIScreen.main.bounds.width * 0.3
                        ))
                        .opacity(0.9)
                        .foregroundStyle(.blue)

                    ZStack {

                        Image("Aquarium")
                            .resizable()
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.7, 2000),
                                height: min(UIScreen.main.bounds.width * 0.8, 700)
                            )
                            .padding(.bottom, 65)
                            .scaleEffect(1.45)

                        
                        
                                 // filter “dirtiness”
                                 Rectangle()
                                     .cornerRadius(5)
                                     .foregroundStyle(.green)
                                     .opacity(clean) // animated opacity
                                     .frame(
                                         width: min(UIScreen.main.bounds.width * 0.84, 2000),
                                         height: min(UIScreen.main.bounds.width * 0.46, 2000)
                                     )
                                     .padding(.bottom, 77)
                             
                        
                        
                        
                        
                        HStack {
                            Spacer()

                            Button {
                                withAnimation(.easeOut(duration: 2.2)) {
                                    clean = 0
                                }
                            } label: {
                                Image("brush")
                                    .resizable()
                                    .frame(
                                        width: min(UIScreen.main.bounds.width * 0.12, 2000),
                                        height: min(UIScreen.main.bounds.width * 0.12, 700)
                                    )
                                    .opacity(clean > 0 ? min(clean * 2.5, 1) : 0)
                                    .animation(.easeInOut(duration: 0.7), value: clean)
                            }
                            .padding(.bottom, 215)
                            .padding(.horizontal, 50)
                            .disabled(clean <= 0)

                        }

                    }
                }

                Image("floor")
                    .resizable()
                    .frame(
                        width: min(UIScreen.main.bounds.width * 0.815, 2000),
                        height: min(UIScreen.main.bounds.width * 0.2, 2000)
                    )
                    .padding(.top, 260)
                    .padding(.horizontal, 50)
                    .opacity(0.85 - clean)

           

                FishMoveView().opacity(1-clean)

                VStack {
                    Spacer()

                    ZStack {
                        Button {
                            editState = .editing
                        } label: {
                            Rectangle()
                                .cornerRadius(30)
                                .foregroundStyle(.white)
                                .opacity(0.3)
                                .frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    height: min(UIScreen.main.bounds.width * 0.2, 90)
                                )
                        }

                        Text("Manage")
                            .font(.system(size: UIScreen.main.bounds.width * 0.07))
                            .foregroundStyle(.black)
                            .opacity(0.8)
                            .bold()
                    }
                    .padding(.bottom, 40)

                    Rectangle()
                        .colorInvert()
                        .opacity(0.6)
                        .frame(
                            width: min(UIScreen.main.bounds.width * 1, 2000),
                            height: min(UIScreen.main.bounds.width * 0.205, 90)
                        )
                        .padding(.bottom, -330)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                WaterView()
                    .frame(height: UIScreen.main.bounds.height + 400)
                    .offset(y: -130)
                    .allowsHitTesting(false)
            )
        }
        else {
            AquariumManageView(editState: $editState)
        }
    }
}

#Preview {
    AquariumView().environmentObject(TabRouter())
}

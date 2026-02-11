//
//  FishDetailsView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct FishDetailsView: View {
    
    @State var fish: Fish              // 👈 required for NavigationLink
    @State var pinned: Bool = true
    @EnvironmentObject var aquarium: AquariumFishList


    
    var body: some View {
        
        ZStack {
            
            WaterView()
                .offset(y: -350)
         
            IconView()
                .padding(.top, 60)

            ZStack {
                Rectangle()
                    .cornerRadius(20)
                    .foregroundStyle(.white)
                    .opacity(0.4)
                    .frame(width: 365, height: 200)
                    .padding(.top, 320)
            }
           
            HStack {
                Spacer()
              
                Button {
                    
                    
                    if !fish.isAquarium {
                        aquarium.addFish(with: "\(fish.speciesName.lowercased())Icon")
                        
                        fish.isAquarium.toggle()
                        
                        aquarium.refresh()
                    }
                                       

                    
                    
                } label: {
                    Image("\(fish.speciesName.lowercased())Icon")
                        .resizable()
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.13, 180),
                            height: min(UIScreen.main.bounds.width * 0.13, 180)
                        )
                        .opacity(0.9)
                }
                .padding(.top, 325)
                .padding(.trailing, 45)
            }
            
            HStack {
                Spacer()
                
                Button {
                    
                    
                    aquarium.removeFish(with: "\(fish.speciesName.lowercased())Icon")
                                  
                                  fish.isAquarium = false

                    aquarium.refresh()
                    
                    
                } label: {
                    Image("\(fish.speciesName.lowercased())Icon") // 👈 was hardcoded
                        .resizable()
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.13, 180),
                            height: min(UIScreen.main.bounds.width * 0.13, 180)
                        )
                        .colorMultiply(.gray)
                        .opacity(0.2)
                }
                .padding(.top, 435)
                .padding(.trailing, 45)
            }
            
            HStack {
                Text("Species: \(fish.speciesName)")
                    .font(.system(size: UIScreen.main.bounds.width * 0.03))
                    .opacity(0.8)
                    .padding(.top, 550)
               
                Spacer()
            }
            .padding()
            .padding()
                
            HStack {
                Spacer()
                Text("Caught: 02/30/1976")
                    .font(.system(size: UIScreen.main.bounds.width * 0.03))
                    .opacity(0.8)
                    .padding(.top, 550)
            }
            .padding()
            .padding()
                
            Rectangle()
                .cornerRadius(30)
                .foregroundStyle(.white)
                .opacity(0.3)
                .frame(width: 365, height: 290)
                .padding(.bottom, 210)
            
            Text("Image Not Found")
                .font(.custom("", size: 40))
                .foregroundStyle(.red)
                .padding(.bottom, 210)
            
            Image(fish.photo)
                .resizable()
                .scaledToFill()
                .frame(width: 335, height: 265)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 210)
            
            HStack {
                Spacer()
                Button {
                    pinned.toggle()
                } label: {
                    Image(pinned ? "anchorUnpinned" : "anchor")
                        .resizable()
                        .frame(
                            width: min(UIScreen.main.bounds.width * 0.08, 180),
                            height: min(UIScreen.main.bounds.width * 0.1, 180)
                        )
                        .foregroundStyle(.white)
                        .opacity(0.9)
                }
                .padding(.trailing, 30)
                .padding(.top, 190)
            }

            VStack {
                Text("Description")
                    .font(.title2)
                    .bold()
                    .padding(.top, 8)
                    
                Text(fish.description)
                    .opacity(0.6)
                
                Text("Add to Aquarium")
                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                    .opacity(0.8)
                    .bold()
                    .padding(.bottom)
                    .frame(
                        width: min(UIScreen.main.bounds.width * 0.8, 2000),
                        alignment: .leading
                    )
                    .padding()
                
                Text("Remove From Aquarium")
                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                    .opacity(0.8)
                    .bold()
                    .padding(.bottom)
                    .frame(
                        width: min(UIScreen.main.bounds.width * 0.8, 2000),
                        alignment: .leading
                    )
            }
            .padding(.top, 300)
    
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(height: 83)
                .padding(.top, 790)
        }
        .padding(.top, -20)
    }
}


#Preview {
    FishDetailsView(
        fish: Fish(
            photo: "clownfish1",
            speciesName: "Clownfish"
        )
    )
}


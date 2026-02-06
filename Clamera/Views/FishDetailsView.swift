//
//  FishDetailsView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct FishDetailsView: View {
    var body: some View {
        
        
        ZStack{
            WaterView()
                .position(x: 200, y: 100)
            
            Text("Fish View")
                .font(.custom("IslandMoments-Regular", size: 80))
                .foregroundStyle(.blue)
                .position(x: 200, y: 80)
            
            Text("Species: Clownfish")
                .font(.custom("", size: 20))
                
                .position(x: 110, y: 140)
            
            Text("Caught: 02/30/1976")
                .font(.custom("", size: 20))
                .position(x: 300, y: 140)
            
            Text("Nemo")
                .font(.custom("", size: 40))
                .foregroundStyle(.black)
                .position(x: 200, y: 200)
            
            Rectangle()
                .cornerRadius(20)
                .foregroundStyle(.white)
                .opacity(0.4)
                .frame(width: 375, height: 300)
            
            Rectangle()
                .cornerRadius(20)
                .foregroundStyle(.black)
                .opacity(0.4)
                .frame(width: 335, height: 255)
            
            Text("Image Not Found")
                .font(.custom("", size: 40))
                .foregroundStyle(.red)
            
            Image("nemo")
                .resizable()
                .scaledToFill()
                .frame(width: 335, height: 265)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            
            Rectangle()
                .cornerRadius(20)
                .foregroundStyle(.white)
                .opacity(0.4)
                .frame(width: 375, height: 200)
                .position(x: 200, y: 670)
            
            Text("Description")
                .font(.custom("", size: 25))
                .position(x: 200, y: 600)
            
            Text("Cool fish I found named Nemo")
                .foregroundStyle(.gray)
                .font(.custom("", size: 20))
                .position(x: 200, y: 630)
            
            Text("Add to Aquarium")
                .font(.custom("", size: 20))
                .position(x: 107, y: 680)
            
            Text("Remove From Aquarium")
                .font(.custom("", size: 20))
                .position(x: 140, y: 725)
            
        }.position(x: 200, y: 350)
        
    }
}

#Preview {
    FishDetailsView()
}

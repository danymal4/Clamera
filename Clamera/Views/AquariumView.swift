//
//  AquariumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct AquariumView: View {
    var body: some View {
        Text("Aquarium")
      
        ZStack{
            WaterView().offset(y: -200)
            Image("Aquarium")
            
            
            
        }
    }
}

#Preview {
    AquariumView()
}

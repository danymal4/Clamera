//
//  WaterView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/29/26.
//

import SwiftUI

struct WaterView: View {
    @State private var move = false

       var body: some View {
           ZStack {
               WaterWave()
                   .fill(Color.blue.opacity(0.6))
                   .offset(x: move ? -20 : 20)

               WaterWave()
                   .fill(Color.cyan.opacity(0.4))
                   .offset(x: move ? 20 : -20)

               WaterWave()
                   .fill(Color.indigo.opacity(0.3))
                   .offset(x: move ? -10 : 10)
           }
           .frame(height: 200)
           .clipped()
           .onAppear {
               withAnimation(
                   .easeInOut(duration: 4)
                       .repeatForever(autoreverses: true)
               ) {
                   move.toggle()
               }
           }
       }
    }

#Preview {
    WaterView()
}

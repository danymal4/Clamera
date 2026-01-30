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
               // Controls y val movements of dark blue
                   .offset(y: move ? -10 : 50)
               // Controls x val movements of dark blue
                   .offset(x: move ? -0 : 10)

               WaterWave()
                   .fill(Color.cyan.opacity(0.4))
               // Controls y val movements of mid blue
                   .offset(y: move ? -25 : 30)
               // Controls x val movements of mid blue
                   .offset(x: move ? 0 : 10)

               WaterWave()
                   .fill(Color.indigo.opacity(0.3))
               // Controls y val movements of light blue
                   .offset(y: move ? -40 : 10)
               // Controls x val movements of light blue
                   .offset(x: move ? 0 : 10)
           }
           
           // Change based on how high waves go so that there is no blank at bottom of screen
           .frame(height: 900)
           .clipped()
           .onAppear {
               withAnimation(
                .easeInOut(duration: 7)
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

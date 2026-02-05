//
//  WaterShipView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/3/26.
//

import SwiftUI

struct WaterShipView: View {
    @State private var move = false

       var body: some View {
      
           ZStack(alignment: .top) {
        
               
               
               
                  
                     
                     Image("waterWave").resizable().scaledToFit().offset(y: 365)
                       .offset(y: move ? -10 : 50)
                       .offset(x: move ? 0 : 10).opacity(0.75)
                     
               Image("flat") // your flat image
                         .resizable()
                         .frame(height: 600 )  // adjust height as needed
                         .clipped().offset(y: 777.6 ).offset(y: move ? -10 : 50).opacity(0.75)
                      
                     
               
               
               
               WaterWave()
                   .fill(Color.cyan.opacity(0.2))
               // Controls y val movements of mid blue
                   .offset(y: move ? -25 : 30)
               // Controls x val movements of mid blue
                   .offset(x: move ? 0 : 10)
               
               WaterWave()
                   .fill(Color.blue.opacity(0.14))
               // Controls y val movements of light blue
                   .offset(y: (move ? -40 : 10) )
               // Controls x val movements of light blue
                   .offset(x: move ? 0 : 10)
         
               Image("sunset22")
                   .resizable()
                   .scaledToFill().frame(maxWidth: 10000, maxHeight: 10000)
                   .clipped()
                   .mask(
                       ZStack {
                           Color.white
                          WaterWave()     .offset(y: (move ? -40 : 10) )
                              
                               .fill(Color.black)  // cut out wave area
                               .blendMode(.destinationOut).scaleEffect(y: 1.0015, anchor: .top)
                       }
                      
                   ).ignoresSafeArea(edges: .top).opacity(0.15)
               
               
               
               HStack{
                   
                   VStack{
                       
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       
                       
                       Image("sailboat").scaleEffect(0.4)  .offset(y: move ? -40 : 10)
                       // Controls x val movements of light blue
                           .offset(x: move ? 0 : -80).opacity(0.9)
                       
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       Spacer()
                       
                       
                       
                   }
                   
                   Spacer()
                   
                   
               }
               
               
           }
           
           
        
               
           
           
           // Change based on how high waves go so that there is no blank at bottom of screen
       
           
           
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
    WaterShipView()
}

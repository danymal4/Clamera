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
        
               
           
              
               

               let defaultWidth: CGFloat = 402
               let defaultHeight: CGFloat = 874
               let currentWidth = UIScreen.main.bounds.width
               let currentHeight = UIScreen.main.bounds.height
               let horizontalScale = max(0, (currentWidth - defaultWidth) / defaultWidth)
               let verticalScale = max(1.0, (currentHeight * 0.985) / defaultHeight)
        

              
               var waveAspect: CGFloat {
                   guard let img = UIImage(named: "waterWave") else { return 1.0 }
                   return img.size.width / img.size.height
               }


               let waveWidth = currentWidth * 1.05
               let waveHeight = waveWidth / waveAspect

               let baseOffsetY = (waveHeight * 0.9) - 15

              
               let yOffsetAdjustment = horizontalScale * waveHeight * 0.15

               let boatScale = 1.0 + (horizontalScale * 0.8)
               let flatHeight: CGFloat = 600
              

               
               Image("waterWave")
                   .resizable()
                   .scaleEffect(x: 1 + (horizontalScale * 0.18), y: 1.0, anchor: .center)
                   .scaledToFit().offset(x: -1)
                   .offset(y: baseOffsetY - 0.3 * yOffsetAdjustment + (move ? -10 : 50))
                   .opacity(0.75)
               
                              
               Image("flat")
                   .resizable()
                   .frame(height: flatHeight)
                   .clipped()
                   .offset(y: 0.96 * verticalScale * (444.5 + baseOffsetY - (0.3 * yOffsetAdjustment)) + (move ? -10 : 50))
                   .opacity(0.75)
               
               
               
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
                              
                               .fill(Color.black)
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
                       
                       
                      
                       Image("sailboat")
                           .scaleEffect(0.4 * boatScale) // original 0.4 multiplied by scaling factor
                           .offset(y: move ? -40 : 10)
                           .offset(x: move ? 0 : -80)
                           .opacity(0.9)
                       
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

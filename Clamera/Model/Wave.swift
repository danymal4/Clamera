//
//  Wave.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/29/26.
//

import Foundation
import SwiftUI
struct WaterWave: Shape {
    var amplitude: CGFloat = 30 // Height of waves
    var waveCount: CGFloat = 2 // Number of waves
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        
        // Starting wave rectangle 1 screen to the left and 2 to the right
        let startX = -rect.width
        let endX = rect.width * 2
        
        // Start the path at the middle and to the left of the area
        path.move(to: CGPoint(x: startX, y: midY))
        
        // Using a loop to create a long continuous wave
        for x in stride(from: startX, to: endX, by: rect.width / waveCount) {
            path.addCurve(
                to: CGPoint(x: x + (rect.width / waveCount), y: midY),
                
                // control1 pulls the curve up
                // control2 pulls the curve down
                // Both are centered at the horizontal midpoint
                control1: CGPoint(x: x + (rect.width / (waveCount * 2)), y: midY - amplitude),
                control2: CGPoint(x: x + (rect.width / (waveCount * 2)), y: midY + amplitude)
            )
        }

        // Close the shape to ensure it's filled
        path.addLine(to: CGPoint(x: endX, y: rect.height * 10))
        path.addLine(to: CGPoint(x: startX, y: rect.height * 10))
        path.closeSubpath()

        return path
    }
}

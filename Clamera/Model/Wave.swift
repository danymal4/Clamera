//
//  Wave.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/29/26.
//

import Foundation
import SwiftUICore
struct WaterWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY

        path.move(to: CGPoint(x: 0, y: midY))

        path.addCurve(
            to: CGPoint(x: rect.width / 2, y: midY),
            control1: CGPoint(x: rect.width * 0.25, y: midY - 30),
            control2: CGPoint(x: rect.width * 0.25, y: midY + 30)
        )

        path.addCurve(
            to: CGPoint(x: rect.width, y: midY),
            control1: CGPoint(x: rect.width * 0.75, y: midY - 30),
            control2: CGPoint(x: rect.width * 0.75, y: midY + 30)
        )

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

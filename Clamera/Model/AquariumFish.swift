//
//  AquariumFish.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/2/26.
//

import SwiftUI

final class AquariumFish: Identifiable, ObservableObject {
    let id = UUID()
    @Published var imageName: String
    @Published var size: CGSize
    let horizontalRange: ClosedRange<CGFloat>
    let verticalRange: ClosedRange<CGFloat>
    @Published var swimDuration: Double
    let phaseOffset: Double
    @Published var isActive : Bool
    @Published var isShown : Bool
    

    init(
        imageName: String,
        size: CGSize,
        horizontalRange: ClosedRange<CGFloat>,
        verticalRange: ClosedRange<CGFloat>,
        swimDuration: Double,
        phaseOffset: Double,
        isActive: Bool,
        isShown: Bool
    ) {
        self.imageName = imageName
        self.size = size
        self.horizontalRange = horizontalRange
        self.verticalRange = verticalRange
        self.swimDuration = swimDuration
        self.phaseOffset = phaseOffset
        self.isActive = isActive
        self.isShown = isShown
    }
}

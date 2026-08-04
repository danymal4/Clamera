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
                .fill(Color.cyan.opacity(0.15))
                .offset(y: move ? -10 : 50)
                .offset(x: move ? -0 : 10)

            WaterWave()
                .fill(Color.cyan.opacity(0.2))
                .offset(y: move ? -25 : 30)
                .offset(x: move ? 0 : 10)

            WaterWave()
                .fill(Color.blue.opacity(0.15))
                .offset(y: move ? -40 : 10)
                .offset(x: move ? 0 : 10)
        }
        .animation(
            .easeInOut(duration: 7)
                .repeatForever(autoreverses: true),
            value: move
        )
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            // Wait until the first layout pass has settled before animating,
            // otherwise the shape's frame is still resolving on cold launch
            // and SwiftUI blends the unsettled + final geometry mid-animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                move = true
            }
        }
    }
}

#Preview {
    WaterView()
}

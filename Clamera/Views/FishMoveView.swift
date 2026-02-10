import SwiftUI

struct FishMoveView: View {
    struct Fish: Identifiable {
        let id = UUID()
        let imageName: String
        let size: CGSize
        let horizontalRange: ClosedRange<CGFloat>
        let verticalRange: ClosedRange<CGFloat>
        let swimDuration: Double
        let phaseOffset: Double
    }

    struct Ripple: Identifiable {
        let id = UUID()
        let position: CGPoint
        var size: CGFloat = 0
        var opacity: Double = 1.0  // <-- add opacity
    }

    @State private var fishList: [Fish] = [
        Fish(imageName: "clownfishIcon", size: CGSize(width: 80, height: 50),
             horizontalRange: -120...120, verticalRange: -30...30,
             swimDuration: 8, phaseOffset: 0),
        Fish(imageName: "puffer", size: CGSize(width: 70, height: 45),
             horizontalRange: -130...100, verticalRange: -40...40,
             swimDuration: 10, phaseOffset: 1),
        Fish(imageName: "grouper", size: CGSize(width: 90, height: 55),
             horizontalRange: -100...128, verticalRange: -20...20,
             swimDuration: 12, phaseOffset: 2)
    ]

    @State private var speedMultipliers: [UUID: Double] = [:]
    @State private var zIndices: [UUID: Double] = [:]
    @State private var ripples: [Ripple] = []

    let zTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            TimelineView(AnimationTimelineSchedule()) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    
                    // --- Ripples ---
                    ForEach(ripples) { ripple in
                        Circle()
                            .stroke(Color.white, lineWidth: 1.7)
                            .frame(width: ripple.size, height: ripple.size)
                            .position(ripple.position)
                            .opacity(ripple.opacity)
                            .animation(.easeOut(duration: 0.7), value: ripple.size)
                    }

                    // --- Fish ---
                    ForEach(fishList) { fish in
                        let speed = speedMultipliers[fish.id] ?? 1.0
                        let z = zIndices[fish.id] ?? 0

                        // Adjusted time along the curve
                        let adjustedTime = (now + fish.phaseOffset) * speed
                        let rawProgress = adjustedTime / fish.swimDuration * 2 * .pi
                        let progress = sin(rawProgress)
                        let facingRight = progress >= 0

                        // Offsets along sine path
                        let xOffset = fish.horizontalRange.lowerBound + (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) * ((progress + 1)/2)
                        let yOffset = fish.verticalRange.lowerBound + (fish.verticalRange.upperBound - fish.verticalRange.lowerBound) * ((sin(adjustedTime * 1.5) + 1)/2)

                        // Tail wiggle
                        let tailAngle = 12 * sin(adjustedTime * 2)

                        // Forward movement check
                        let deltaX = (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound)/1000
                        let projectedX = xOffset + (facingRight ? deltaX : -deltaX)
                        let canBoost = (facingRight && projectedX > xOffset) || (!facingRight && projectedX < xOffset)

                        // Fish center for ripple (+70 y-offset)
                        let fishCenter = CGPoint(
                            x: geo.frame(in: .local).midX + xOffset,
                            y: geo.frame(in: .local).midY + (yOffset - 70)
                        )

                        Image(fish.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: fish.size.width, height: fish.size.height)
                            .rotation3DEffect(.degrees(facingRight ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                            .rotationEffect(.degrees(tailAngle))
                            .offset(x: xOffset, y: yOffset)
                            .opacity(0.95)
                            .zIndex(z)
                            .animation(.easeInOut(duration: 0.3), value: facingRight)
                            .onTapGesture {
                                if canBoost {
                                    // Speed boost
                                    withAnimation(.linear(duration: 0.2)) {
                                        speedMultipliers[fish.id] = 1.6
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation(.linear(duration: 0.5)) {
                                            speedMultipliers[fish.id] = 1.0
                                        }
                                    }

                                    // Ripple at fish center
                                    addRipple(at: fishCenter)
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 150)
                .onReceive(zTimer) { _ in
                    updateZIndices()
                }
            }
        }
    }

    // MARK: - Random Z-layer
    private func updateZIndices() {
        var newZ = zIndices
        if let randomFish = fishList.randomElement() {
            newZ[randomFish.id] = Double.random(in: 1...3)
            for f in fishList where f.id != randomFish.id {
                newZ[f.id] = Double.random(in: 0...1)
            }
            zIndices = newZ
        }
    }

    // MARK: - Ripples
    private func addRipple(at position: CGPoint) {
        var ripple = Ripple(position: position)
        ripples.append(ripple)
        let index = ripples.count - 1

        // Animate size growth and fade out
        withAnimation(.easeOut(duration: 1.1)) {
            ripples[index].size = 120
            ripples[index].opacity = 0.0   // <-- fade out
        }

        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

#Preview {
    FishMoveView()
}


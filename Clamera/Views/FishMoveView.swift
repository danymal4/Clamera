import SwiftUI

struct FishMoveView: View {

    struct Ripple: Identifiable {
        let id = UUID()
        let position: CGPoint
        var size: CGFloat = 0
        var opacity: Double = 1.0
    }

    @ObservedObject var aquarium: AquariumFishList   // shared fish list
    @State private var speedMultipliers: [UUID: Double] = [:]
    @State private var ripples: [Ripple] = []

    // --- RESET LOGIC ---
    @State private var startTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    @State private var verticalOffsets: [UUID: CGFloat] = [:]  // stores small vertical adjustments per fish

    var body: some View {

        GeometryReader { geo in
            TimelineView(AnimationTimelineSchedule()) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate

                // Adjusted time relative to the startTime (resets on appear)
                let adjustedGlobalTime = now - startTime

                ZStack {

                    // --- Ripples ---
                    ForEach(ripples) { ripple in
                        let fishSizeMultiplier = ripple.size / 120
                        Circle()
                            .stroke(Color.white, lineWidth: 1.7 * (1 + 0.2 * (1.8 * fishSizeMultiplier)))
                            .frame(width: ripple.size, height: ripple.size)
                            .position(ripple.position)
                            .opacity(ripple.opacity)
                            .animation(.easeOut(duration: 0.7), value: ripple.size)
                    }

                    // --- Fish ---
                    ForEach(aquarium.fish) { fish in
                        let speed = speedMultipliers[fish.id] ?? 1.0
                        let adjustedTime = (adjustedGlobalTime + fish.phaseOffset) * speed
                        let rawProgress = adjustedTime / fish.swimDuration * 2 * .pi
                        let progress = sin(rawProgress)
                        let facingRight = progress >= 0

                        // Horizontal movement
                        let xOffset = fish.horizontalRange.lowerBound +
                        (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) * ((progress + 1) / 2)

                        // Vertical drifting & bobbing
                        let padding: CGFloat = 20
                        let safeLower = fish.verticalRange.lowerBound + padding
                        let safeUpper = fish.verticalRange.upperBound - padding
                        let driftSpeed = 0.12 + (Double(fish.phaseOffset) * 0.01)
                        let driftAmplitude = (safeUpper - safeLower) / 2
                        let driftCenter = (safeUpper + safeLower) / 2
                        
                        // Use verticalOffsets to slightly desync fish within their safe vertical range
                        let randomOffset = verticalOffsets[fish.id] ?? 0
                        let driftingBaseY = driftCenter + driftAmplitude * sin(adjustedTime * driftSpeed + fish.phaseOffset) + randomOffset
                        let amplitude = (fish.verticalRange.upperBound - fish.verticalRange.lowerBound) / 4
                        let yOffset = driftingBaseY + amplitude * sin(adjustedTime * 1.5)

                        // Tail angle & boost
                        let tailAngle = 12 * sin(adjustedTime * 2)
                        let deltaX = (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) / 1000
                        let projectedX = xOffset + (facingRight ? deltaX : -deltaX)
                        let canBoost = (facingRight && projectedX > xOffset) ||
                        (!facingRight && projectedX < xOffset)

                        let fishCenter = CGPoint(
                            x: geo.frame(in: .local).midX + xOffset,
                            y: geo.frame(in: .local).midY + yOffset - 70
                        )

                        ZStack {
                            if fish.isShown {
                                Image(fish.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: fish.size.width, height: fish.size.height)
                                    .rotation3DEffect(
                                        .degrees(facingRight ? 0 : 180),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                    .rotationEffect(.degrees(tailAngle))
                                    .offset(x: xOffset, y: yOffset)
                                    .opacity(fish.isActive ? 0.95 : 0)
                                    .animation(.easeInOut(duration: 0.3), value: facingRight)
                                    .onTapGesture {
                                        if canBoost {
                                            withAnimation(.linear(duration: 0.2)) {
                                                speedMultipliers[fish.id] = 1.6
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                withAnimation(.linear(duration: 0.5)) {
                                                    speedMultipliers[fish.id] = 1.0
                                                }
                                            }

                                            addRipple(for: fish, at: fishCenter)
                                        }
                                    }
                            }
                        }
                        .zIndex(Double(yOffset))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 150)
                // --- RESET ON APPEAR ---
                .onAppear {
                    startTime = Date().timeIntervalSinceReferenceDate
                    resetVerticalOffsets()
                }
            }
        }
    }

    private func addRipple(for fish: AquariumFish, at position: CGPoint) {
        var ripple = Ripple(position: position)
        ripples.append(ripple)
        let index = ripples.count - 1

        withAnimation(.easeOut(duration: 1.1)) {
            if fish.isActive {
                let averageFishSize = (fish.size.width + fish.size.height) / 2
                ripples[index].size = 120 * (averageFishSize / 50)
                ripples[index].opacity = 0.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }

    // --- Vertical-only reset logic ---
    private func resetVerticalOffsets() {
        for fish in aquarium.fish {
            let padding: CGFloat = 10
            let minY = (fish.verticalRange.lowerBound + padding  + 50)
            let maxY = (fish.verticalRange.upperBound - padding - 50)

            // Small random offset within safe range
            verticalOffsets[fish.id] = CGFloat.random(in: minY...maxY)
        }

        // Reset speed multipliers to default
        speedMultipliers = [:]
    }
}

#Preview {
    FishMoveView(aquarium: AquariumFishList())
}

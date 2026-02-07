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

    @State private var fishList: [Fish] = [
        Fish(imageName: "clownFish", size: CGSize(width: 80, height: 50),
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
    
    let zTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            TimelineView(AnimationTimelineSchedule()) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    ForEach(fishList) { fish in
                        let speed = speedMultipliers[fish.id] ?? 1.0
                        let z = zIndices[fish.id] ?? 0
                        
                        // Adjusted time along the curve for boost
                        let adjustedTime = (now + fish.phaseOffset) * speed
                        let rawProgress = adjustedTime / fish.swimDuration * 2 * .pi
                        let progress = sin(rawProgress)
                        let facingRight = progress >= 0
                        
                        // Horizontal & vertical offsets along sine path
                        let xOffset = fish.horizontalRange.lowerBound + (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) * ((progress + 1)/2)
                        let yOffset = fish.verticalRange.lowerBound + (fish.verticalRange.upperBound - fish.verticalRange.lowerBound) * ((sin(adjustedTime * 1.5) + 1)/2)
                        
                        // Tail wiggle
                        let tailAngle = 12 * sin(adjustedTime * 2)
                        let position = CGPoint(x: xOffset + geo.size.width/2, y: yOffset + geo.size.height/2)
                        
                        // Check if fish is moving forward along x-axis
                        let deltaX = (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound)/1000
                        let projectedX = xOffset + (facingRight ? deltaX : -deltaX)
                        let canBoost = (facingRight && projectedX > xOffset) || (!facingRight && projectedX < xOffset)

                        Image(fish.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: fish.size.width, height: fish.size.height)
                            .rotation3DEffect(.degrees(facingRight ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                            .rotationEffect(.degrees(tailAngle))
                            .offset(x: xOffset, y: yOffset)
                            .opacity(0.9)
                            .zIndex(z)
                            .animation(.easeInOut(duration: 0.3), value: facingRight)
                            .onTapGesture {
                                let distance = hypot(position.x - geo.size.width/2, position.y - geo.size.height/2)
                                if distance < 100 && canBoost {
                                    // Temporarily boost speed along curve
                                    withAnimation(.linear(duration: 0.2)) {
                                        speedMultipliers[fish.id] = 1.6
                                    }
                                    // Return to normal smoothly
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation(.linear(duration: 0.5)) {
                                            speedMultipliers[fish.id] = 1.0
                                        }
                                    }
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

    // Random Z-layer
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
}

#Preview {
    FishMoveView()
}


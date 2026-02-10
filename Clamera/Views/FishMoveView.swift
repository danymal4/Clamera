import SwiftUI

// MARK: - Fish & Fish List

final class AquariumFish: Identifiable, ObservableObject {
    let id = UUID()
    @Published var imageName: String       // changing icon
    @Published var size: CGSize
    let horizontalRange: ClosedRange<CGFloat>
    let verticalRange: ClosedRange<CGFloat>
    @Published var swimDuration: Double    // changing speed
    let phaseOffset: Double

    init(
        imageName: String,
        size: CGSize,
        horizontalRange: ClosedRange<CGFloat>,
        verticalRange: ClosedRange<CGFloat>,
        swimDuration: Double,
        phaseOffset: Double
    ) {
        self.imageName = imageName
        self.size = size
        self.horizontalRange = horizontalRange
        self.verticalRange = verticalRange
        self.swimDuration = swimDuration
        self.phaseOffset = phaseOffset
    }
}

final class AquariumFishList: ObservableObject {
    @Published var fish: [AquariumFish]
    
    init() {
        self.fish = [
            AquariumFish(
                imageName: "clownfishIcon",
                size: CGSize(width: 80, height: 50),
                horizontalRange: -120...120,
                verticalRange: -30...30,
                swimDuration: 8,
                phaseOffset: 0
            ),
            AquariumFish(
                imageName: "puffer",
                size: CGSize(width: 70, height: 45),
                horizontalRange: -130...100,
                verticalRange: -40...40,
                swimDuration: 10,
                phaseOffset: 1
            ),
            AquariumFish(
                imageName: "grouper",
                size: CGSize(width: 90, height: 55),
                horizontalRange: -100...128,
                verticalRange: -20...20,
                swimDuration: 12,
                phaseOffset: 2
            )
        ]
    }

    // convenience methods
    func updateSpeed(for fish: AquariumFish, to newDuration: Double) {
        fish.swimDuration = newDuration
    }
    
    func updateSize(for fish: AquariumFish, to newSize: CGSize) {
        fish.size = newSize
    }
}



import SwiftUI

// MARK: - FishMoveView
struct FishMoveView: View {

    struct Ripple: Identifiable {
        let id = UUID()
        let position: CGPoint
        var size: CGFloat = 0
        var opacity: Double = 1.0
    }

    @ObservedObject var aquarium: AquariumFishList   // shared fish list
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
                    ForEach(aquarium.fish) { fish in
                        let speed = speedMultipliers[fish.id] ?? 1.0
                        let z = zIndices[fish.id] ?? 0

                        let adjustedTime = (now + fish.phaseOffset) * speed
                        let rawProgress = adjustedTime / fish.swimDuration * 2 * .pi
                        let progress = sin(rawProgress)
                        let facingRight = progress >= 0

                        let xOffset = fish.horizontalRange.lowerBound +
                        (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) * ((progress + 1) / 2)

                        let yOffset = fish.verticalRange.lowerBound +
                        (fish.verticalRange.upperBound - fish.verticalRange.lowerBound) *
                        ((sin(adjustedTime * 1.5) + 1) / 2)

                        let tailAngle = 12 * sin(adjustedTime * 2)

                        let deltaX = (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) / 1000
                        let projectedX = xOffset + (facingRight ? deltaX : -deltaX)
                        let canBoost = (facingRight && projectedX > xOffset) ||
                                       (!facingRight && projectedX < xOffset)

                        let fishCenter = CGPoint(
                            x: geo.frame(in: .local).midX + xOffset,
                            y: geo.frame(in: .local).midY + (yOffset - 70)
                        )

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
                            .opacity(0.95)
                            .zIndex(z)
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
                                    // Pass fish for ripple scaling
                                    addRipple(for: fish, at: fishCenter)
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

    private func updateZIndices() {
        var newZ = zIndices
        if let randomFish = aquarium.fish.randomElement() {
            newZ[randomFish.id] = Double.random(in: 1...3)
            for f in aquarium.fish where f.id != randomFish.id {
                newZ[f.id] = Double.random(in: 0...1)
            }
            zIndices = newZ
        }
    }

    // ✅ Scales ripple size relative to fish but keeps the animation exactly like before
    private func addRipple(for fish: AquariumFish, at position: CGPoint) {
        var ripple = Ripple(position: position)
        ripples.append(ripple)
        let index = ripples.count - 1

        // Animate to scaled size
        withAnimation(.easeOut(duration: 1.1)) {
            ripples[index].size = 120 * ((fish.size.width + fish.size.height) / 2 / 50) // factor relative to default size
            ripples[index].opacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

#Preview {
    FishMoveView(aquarium: AquariumFishList())
}

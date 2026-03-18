import SwiftUI
import AVFoundation

struct FishMoveView: View {

    struct Ripple: Identifiable {
        let id = UUID()
        let position: CGPoint
        var size: CGFloat = 0
        var opacity: Double = 0.9
    }

    @ObservedObject var aquarium: AquariumFishList

    @State private var speedMultipliers: [UUID: Double] = [:]
    @State private var ripples: [Ripple] = []
    @State private var activeChain: Set<UUID> = []

    @State private var startTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    @State private var verticalOffsets: [UUID: CGFloat] = [:]

    // Sound player
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        GeometryReader { geo in
            TimelineView(AnimationTimelineSchedule()) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let adjustedGlobalTime = now - startTime

                ZStack {
                    // MARK: Ripples
                    ForEach(ripples) { ripple in
                        let fishSizeMultiplier = ripple.size / 30
                        let lineWidth = 1.7 * pow(fishSizeMultiplier, 0.6)

                        Circle()
                            .stroke(Color.white, lineWidth: max(lineWidth, 0.3))
                            .frame(width: ripple.size, height: ripple.size)
                            .position(ripple.position)
                            .opacity(ripple.opacity)
                            .animation(.easeOut(duration: 0.7), value: ripple.size)
                    }

                    // MARK: Fish
                    ForEach(aquarium.fish) { fish in
                        let boost = speedMultipliers[fish.id] ?? 1.0
                        let speed = boost

                        let adjustedTime = (adjustedGlobalTime + fish.phaseOffset) * speed
                        let rawProgress = adjustedTime / fish.swimDuration * 2 * .pi
                        let progress = sin(rawProgress)
                        let facingRight = progress >= 0

                        // Horizontal motion
                        let xOffset = fish.horizontalRange.lowerBound +
                                      (fish.horizontalRange.upperBound - fish.horizontalRange.lowerBound) * ((progress + 1) / 2)

                        // Vertical drifting & bobbing
                        let padding: CGFloat = 20
                        let safeLower = fish.verticalRange.lowerBound + padding
                        let safeUpper = fish.verticalRange.upperBound - padding
                        let driftSpeed = 0.12 + (Double(fish.phaseOffset) * 0.01)
                        let driftAmplitude = (safeUpper - safeLower) / 2
                        let driftCenter = (safeUpper + safeLower) / 2
                        let randomOffset = verticalOffsets[fish.id] ?? 0

                        let driftingBaseY =
                            driftCenter +
                            driftAmplitude * sin(adjustedTime * driftSpeed + fish.phaseOffset) +
                            randomOffset

                        let amplitude = (fish.verticalRange.upperBound - fish.verticalRange.lowerBound) / 4
                        let yOffset = driftingBaseY + amplitude * sin(adjustedTime * 1.5)

                        // Tail angle
                        let tailAngle = 12 * sin(adjustedTime * 2)

                        // Fish center for ripple
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
                            .opacity(fish.isShown ? (fish.isActive ? 0.95 : 0) : 0)
                            .animation(.easeInOut(duration: 0.3), value: facingRight)
                            .onTapGesture {
                                // Only tap fish ripple once
                                if !activeChain.contains(fish.id) {
                                    let tapBoost = Double.random(in: 1.5...1.6)
                                    withAnimation(.linear(duration: 0.2)) { speedMultipliers[fish.id] = tapBoost }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation(.linear(duration: 0.5)) { speedMultipliers[fish.id] = 1.0 }
                                    }

                                    // Play plopp sound
                                    playPloppSound(for: fish)

                                    addRipple(for: fish, at: fishCenter)

                                    // Trigger chain reaction WITHOUT chain ripples
                                    triggerBoost(for: fish, chainDepth: Int.random(in: 0...2))
                                }
                            }
                            .zIndex(Double(yOffset))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 150)
                .onAppear {
                    startTime = Date().timeIntervalSinceReferenceDate
                    resetVerticalOffsets()
                }
            }
        }
    }

    // MARK: Boost & chain (no chain ripples)
    private func triggerBoost(for fish: AquariumFish, chainDepth: Int, isChain: Bool = true) {
        guard !activeChain.contains(fish.id) else { return }
        activeChain.insert(fish.id)

        let boost: Double
        let animationDuration: Double
        if isChain {
            boost = Double.random(in: 1.1...1.25)
            animationDuration = Double.random(in: 0.35...0.6)
        } else {
            boost = Double.random(in: 1.5...1.55)
            animationDuration = 0.3
        }

        withAnimation(.linear(duration: animationDuration)) {
            speedMultipliers[fish.id] = boost
        }

        let resetDuration = isChain ? animationDuration + 0.5 : 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + resetDuration) {
            withAnimation(.linear(duration: 0.4)) { speedMultipliers[fish.id] = 1.0 }
            activeChain.remove(fish.id)
        }

        // Chain reaction only
        guard chainDepth > 0 else { return }
        let otherFish = aquarium.fish.filter { $0.id != fish.id }.shuffled().prefix(Int.random(in: 0...2))
        for other in otherFish {
            let delay = Double.random(in: 0.3...0.6) * 2 + Double.random(in: 0.05...0.2)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.triggerBoost(for: other, chainDepth: chainDepth - 1)
            }
        }
    }

    // MARK: Ripple for tapped fish only
    private func addRipple(for fish: AquariumFish, at position: CGPoint) {
        var ripple = Ripple(position: position)
        ripples.append(ripple)
        let index = ripples.count - 1
        withAnimation(.easeOut(duration: 1.1)) {
            if fish.isActive && fish.isShown {
                let avgSize = (fish.size.width + fish.size.height) / 2
                ripples[index].size = 80 * (avgSize / 50)
                ripples[index].opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }

   
    private func playPloppSound(for fish: AquariumFish) {
        guard let url = Bundle.main.url(forResource: "plopp", withExtension: "wav") else { return }

        do {
            // Use shared @State audioPlayer
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.enableRate = true

            // Small random pitch variation (subtle)
            audioPlayer?.rate = Float.random(in: 0.97...1.03)

            // Volume scales with fish size (small fish quieter, big fish louder)
            let minSize: CGFloat = 20
            let maxSize: CGFloat = 200
            let minVolume: Float = 0.2
            let maxVolume: Float = 1.0
            let clampedSize = max(min(fish.size.width, maxSize), minSize)

            audioPlayer?.volume = minVolume + Float((clampedSize - minSize) / (maxSize - minSize)) * (maxVolume - minVolume)

            audioPlayer?.play()
        } catch {
            print("Error playing plopp sound: \(error)")
        }
    }
    
    // MARK: Reset vertical offsets
    private func resetVerticalOffsets() {
        for fish in aquarium.fish {
            let padding: CGFloat = 10
            let minY = fish.verticalRange.lowerBound + padding + 50
            let maxY = fish.verticalRange.upperBound - padding - 50
            verticalOffsets[fish.id] = CGFloat.random(in: minY...maxY)
        }
        speedMultipliers = [:]
    }
}

#Preview {
    FishMoveView(aquarium: AquariumFishList())
}

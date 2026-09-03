//
//  AquariumState.swift
//  Clamera
//

import SwiftUI
import AVFoundation

final class AquariumState: ObservableObject {
    @Published var clean: Double = 0.0
    
    @Published var bubbleVisibility: Double = 1.0 {
        didSet {
            if bubbleVisibility <= 0 {
                stopBubbleSound()
            } else if bubbleAmount > 0 {
                startBubbleSound()
            }
        }
    }
    
    @Published var bubbleAmount: Double = 1.0 {
        didSet {
            if bubbleAmount <= 0 {
                stopBubbleSound()
            } else if bubbleVisibility > 0 {
                if bubblePlayer == nil {
                    startBubbleSound()
                } else {
                    updateBubbleVolume()
                }
            }
        }
    }
    
    @Published var lastUpdate: Date = Date()
    @Published var activeScreens: Set<String> = []
    
    let maxClean: Double = 0.3
    private(set) var pendingClean: Double = 0.0
    private var targetClean: Double? = nil

    // MARK: - Centralized Audio Engine
    private var bubblePlayer: AVAudioPlayer?

    func startBubbleSound() {
        guard bubbleVisibility > 0 && bubbleAmount > 0 else {
            stopBubbleSound()
            return
        }
        
        // Re-create the player if it was stopped/destroyed
        if bubblePlayer == nil {
            guard let url = Bundle.main.url(forResource: "bubble", withExtension: "wav") else {
                print("Could not find bubble.wav in bundle")
                return
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                self.bubblePlayer = player
            } catch {
                print("Error initializing bubble player: \(error)")
                return
            }
        }
        
        updateBubbleVolume()
        
        if let player = bubblePlayer, !player.isPlaying {
            player.play()
        }
    }

    func stopBubbleSound() {
        bubblePlayer?.stop()
        bubblePlayer = nil
    }

    func updateBubbleVolume() {
        guard let player = bubblePlayer else { return }
        let effectiveVolume = (bubbleVisibility > 0 && bubbleAmount > 0) ? Float(bubbleAmount) * 0.5 : 0.0
        player.volume = effectiveVolume
    }

    // MARK: - Screen Lifecycle & Cleaning
    func markActive(_ screen: String) {
        activeScreens.insert(screen)
        commitPendingClean()
    }
    
    func markInactive(_ screen: String) {
        activeScreens.remove(screen)
        pendingClean = clean
    }
    
    var isActiveScreen: Bool {
        !activeScreens.isEmpty
    }
    
    func updateClean(by increment: Double) {
        if let target = targetClean {
            let delta = (target - clean) * 0.8
            clean += delta
            if abs(clean - target) < 0.01 {
                clean = target
                pendingClean = clean
                targetClean = nil
            }
        } else {
            clean = min(clean + increment, maxClean)
        }
    }
    
    func commitPendingClean() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let target = targetClean, target == 0 {
                clean = min(pendingClean, clean)
            } else {
                clean = max(pendingClean, clean)
            }
        }
    }
    
    func updatePendingClean(to value: Double) {
        if let target = targetClean {
            let delta = (target - pendingClean) * 0.8
            pendingClean += delta
            if abs(pendingClean - target) < 0.01 {
                pendingClean = target
                targetClean = nil
                clean = pendingClean
            }
        } else {
            pendingClean = min(value, maxClean)
        }
    }
    
    func cleanNow() {
        targetClean = 0
    }
}

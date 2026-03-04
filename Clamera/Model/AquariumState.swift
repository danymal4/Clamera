//
//  AquariumState.swift
//  Clamera
//
//  Created by Kaes van Dolder (student LM) on 3/3/26.
//

import SwiftUI

final class AquariumState: ObservableObject {
    @Published var clean: Double = 0.3
    @Published var bubbleVisibility: Double = 1.0
    @Published var bubbleAmount: Double = 1.0
    @Published var lastUpdate: Date = Date()
    
    // Track active screens
    @Published var activeScreens: Set<String> = []
    
    let maxClean: Double = 0.3
    private(set) var pendingClean: Double = 0.3
    private var targetClean: Double? = nil
    
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
                // If brush is active, keep the smaller of pendingClean and current clean
                clean = min(pendingClean, clean)
            } else {
                // Otherwise, take the larger to respect increments
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

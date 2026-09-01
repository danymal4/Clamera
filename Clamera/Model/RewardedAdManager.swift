//
//  RewardedAdManager.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/5/26.
//

import GoogleMobileAds
import SwiftUI

@MainActor
class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published var rewardedAd: RewardedAd?
    @Published var adLoaded = true // Keep true so button is always active for testing

    private let testAdUnitID = "ca-app-pub-3940256099942544/5224354917"

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        Task {
            do {
                let ad = try await RewardedAd.load(
                    with: testAdUnitID,
                    request: Request()
                )
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                self.adLoaded = true
            } catch {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                self.adLoaded = true
            }
        }
    }

    func showAd(onRewardEarned: @escaping () -> Void) {
        guard let rewardedAd = rewardedAd else {
            // Instant reward fallback for simulator/testing environments
            onRewardEarned()
            return
        }

        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first {
            
            rewardedAd.present(from: rootViewController) {
                onRewardEarned()
            }
        } else {
            onRewardEarned()
        }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            self.loadAd()
        }
    }
}

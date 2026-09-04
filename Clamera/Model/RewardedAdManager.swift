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
    @Published var isProcessingAdRequest = false

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
            } catch {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
            }
        }
    }

    func showAd(onRewardEarned: @escaping () -> Void) {
        guard !isProcessingAdRequest else {
            print("RewardedAdManager: Ignoring showAd() — a request is already in progress.")
            return
        }

        guard let rewardedAd = rewardedAd,
              let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first else {
            #if DEBUG
            // Simulator/testing convenience ONLY — never compiled into a
            // real release build, so it can't be exploited by spam-tapping
            // before a real ad has loaded in production.
            print("RewardedAdManager: [DEBUG] No ad available, granting fallback reward for testing.")
            onRewardEarned()
            #else
            print("RewardedAdManager: No ad ready yet — ignoring tap.")
            #endif
            return
        }

        isProcessingAdRequest = true
        self.rewardedAd = nil // consumed — can never be presented again

        rewardedAd.present(from: rootViewController) {
            // Only grant the reward here. isProcessingAdRequest resets in
            // adDidDismissFullScreenContent below, once the ad has
            // genuinely finished closing — not here.
            onRewardEarned()
        }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            self.isProcessingAdRequest = false
            self.loadAd()
        }
    }
}

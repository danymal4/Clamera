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
    @Published var adLoaded = false

    // Google's official test Ad Unit ID for rewarded video ads
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
                self.adLoaded = false
            }
        }
    }

    func showAd(onRewardEarned: @escaping () -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("Ad wasn't ready yet.")
            loadAd()
            return
        }

        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first {
            
            rewardedAd.present(from: rootViewController) {
                onRewardEarned()
            }
        }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            self.adLoaded = false
            self.loadAd()
        }
    }
}

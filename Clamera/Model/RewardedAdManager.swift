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

    // Google's official sample rewarded ad unit — guaranteed to always
    // fill instantly, on any device, with zero risk of AdMob flagging your
    // own testing as invalid traffic. DEBUG builds (Xcode runs, including
    // TestFlight-adjacent local testing) always use this. Release builds
    // (Archive -> App Store) use the real, live ad unit.
    #if DEBUG
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    private let adUnitID = "ca-app-pub-4800222326379004/9343455740"
    #endif

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        Task {
            do {
                // No App Tracking Transparency prompt is shown in this app, so
                // there is no user consent to key ads to cross-app activity.
                // Explicitly mark every request non-personalized (Google's
                // documented "npa=1" flag) rather than leaving it to the
                // SDK's default — ads still show and still pay, they're just
                // based on this app's own context instead of the user's
                // wider ad history.
                let extras = Extras()
                extras.additionalParameters = ["npa": "1"]
                let request = Request()
                request.register(extras)

                let ad = try await RewardedAd.load(
                    with: adUnitID,
                    request: request
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

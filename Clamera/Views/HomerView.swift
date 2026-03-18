//
//  HomerView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/4/26.
import SwiftUI
import AVFoundation

enum ViewState {
    case home, aquarium, profile, caught, album, social, settings
}

final class TabRouter: ObservableObject {
    @Published var viewState: ViewState = .home
}

struct HomerView: View {
    @EnvironmentObject var aquarium: AquariumFishList
    @EnvironmentObject var speciesStore: SpeciesStore
    @EnvironmentObject var aquariumState: AquariumState

    @StateObject private var tabRouter = TabRouter()
    @State private var cleanTimer: Timer?
    @State private var lastUpdate: Date = Date()

    @State private var showAquariumBottomBar: Bool = true
    @State private var bottomBarWorkItem: DispatchWorkItem?

    // MARK: - Bubble audio
    @State private var bubblePlayer: AVAudioPlayer?
    @State private var fadeTimer: Timer?

    var body: some View {
        ZStack(alignment: .bottom) {

            Group {
                switch tabRouter.viewState {
                case .home: NavigationStack { HomeRevised() }
                case .caught: NavigationStack { CatchView() }
                case .album: NavigationStack { AlbumView() }.tint(.cyan)
                case .aquarium:
                    NavigationStack {
                        AquariumView(
                            showBottomBar: $showAquariumBottomBar,
                            resetBottomBarTimer: resetBottomBarTimer
                        )
                        .onAppear {
                            aquariumState.markActive("aquarium")
                            lastUpdate = Date()
                            aquariumState.commitPendingClean()
                            resetBottomBarTimer()
                        }
                        .onDisappear {
                            aquariumState.markInactive("aquarium")
                            bottomBarWorkItem?.cancel()
                            showAquariumBottomBar = true
                            stopBubbleSound()
                        }
                    }
                case .social: NavigationStack { SocialView() }
                default: NavigationStack { HomeRevised() }
                }
            }
            .environmentObject(tabRouter)
            .environmentObject(aquarium)
            .environmentObject(aquariumState)
            .environmentObject(speciesStore)

            // MARK: - Custom Tab Bar
            HStack(spacing: 0) {
                customTabIcon(systemImage: "house", tab: .home)
                customTabIcon(systemImage: "fish", tab: .caught)
                customTabIcon(systemImage: "book", tab: .album)
                customTabIcon(imageName: "aquariumIcon2", tab: .aquarium)
                customTabIcon(systemImage: "person.2.fill", tab: .social)
            }
            .frame(height: 90)
            .background(
                Color.white
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -3)
            )
            .offset(y: tabRouter.viewState == .aquarium && !showAquariumBottomBar ? 120 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: showAquariumBottomBar)
            .ignoresSafeArea(edges: .bottom)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear { startCleanTimer() }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
            bottomBarWorkItem?.cancel()
            stopBubbleSound()
        }
        .onChange(of: tabRouter.viewState) { newState in
            if newState == .aquarium {
                lastUpdate = Date()
                aquariumState.commitPendingClean()
                if aquariumState.bubbleAmount > 0 {
                    startBubbleSound()
                }
            } else {
                stopBubbleSound()
            }
        }
        // ✅ Listen to bubbleAmount changes from slider or toggle
        .onReceive(aquariumState.$bubbleAmount) { newValue in
            updateBubbleVolume() // always update volume if player exists

            if tabRouter.viewState == .aquarium {
                if newValue > 0 {
                    if bubblePlayer == nil { startBubbleSound() }
                } else {
                    stopBubbleSound()
                }
            } else {
              
                stopBubbleSound()
            }
        }
    }

    // MARK: - Custom Tab Icon Helpers
    private func customTabIcon(systemImage: String, tab: ViewState) -> some View {
        Button(action: {
            tabRouter.viewState = tab
            if tab == .aquarium { resetBottomBarTimer() }
        }) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(tabRouter.viewState == tab ? .cyan : .gray)
                .padding(10)
        }
        .frame(maxWidth: .infinity)
    }

    private func customTabIcon(imageName: String, tab: ViewState) -> some View {
        Button(action: {
            tabRouter.viewState = tab
            if tab == .aquarium { resetBottomBarTimer() }
        }) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(tabRouter.viewState == tab ? .cyan : .gray)
                .padding(10)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Clean Timer
    private func startCleanTimer() {
        cleanTimer?.invalidate()
        let totalDuration: TimeInterval = 60 * 60
        let tickInterval: TimeInterval = 5
        lastUpdate = Date()

        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(self.lastUpdate)
            self.lastUpdate = now

            if aquariumState.isActiveScreen {
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updateClean(by: increment)
            } else {
                let increment = aquariumState.maxClean / totalDuration * delta
                aquariumState.updatePendingClean(
                    to: min(aquariumState.pendingClean + increment, aquariumState.maxClean)
                )
            }
        }
    }

    // MARK: - Bottom Bar Timer
    func resetBottomBarTimer() {
        bottomBarWorkItem?.cancel()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            showAquariumBottomBar = true
        }

        let workItem = DispatchWorkItem {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                showAquariumBottomBar = false
            }
        }

        bottomBarWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }

    // MARK: - Bubble Audio
    private func startBubbleSound() {
        guard bubblePlayer == nil else { return } // already playing
        guard let url = Bundle.main.url(forResource: "bubble", withExtension: "wav") else { return }
        do {
            bubblePlayer = try AVAudioPlayer(contentsOf: url)
            bubblePlayer?.numberOfLoops = -1
            bubblePlayer?.volume = 0
            bubblePlayer?.play()
            updateBubbleVolume()
        } catch {
            print("Error playing bubble sound: \(error)")
        }
    }

    private func stopBubbleSound() {
        fadeTimer?.invalidate()
        bubblePlayer?.stop()
        bubblePlayer = nil
    }

    private func updateBubbleVolume() {
        guard let player = bubblePlayer else { return }
        let scaledVolume = Float(aquariumState.bubbleAmount) * 0.5
        player.volume = scaledVolume
    }
}

#Preview {
    HomerView()
        .environmentObject(AquariumFishList())
        .environmentObject(SpeciesStore())
        .environmentObject(AquariumState())
}

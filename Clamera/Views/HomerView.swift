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
    @EnvironmentObject var user: User
    @EnvironmentObject var leaderboard: LeaderboardData

    @StateObject private var tabRouter = TabRouter()
    @State private var cleanTimer: Timer?
    @State private var lastUpdate: Date = Date()
    

    @State private var showCatchSavedPopup: Bool = false
    @State private var catchSavedMessage: String = ""
    @State private var popupColor: Color = .cyan
    @State private var popupOffset: CGFloat = 150
    
    @State private var showAquariumBottomBar: Bool = true
    @State private var bottomBarWorkItem: DispatchWorkItem?

   
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
                            user.aquariumState.markActive("aquarium")
                            lastUpdate = Date()
                            user.aquariumState.commitPendingClean()
                            resetBottomBarTimer()
                        }
                        .onDisappear {
                            user.aquariumState.markInactive("aquarium")
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
            .environmentObject(user)

   
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
  
            VStack {
                Spacer()
                
                if showCatchSavedPopup {
                    Text(catchSavedMessage)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 22)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(popupColor.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        )
                        .foregroundColor(.white)
                        .offset(y: popupOffset)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .zIndex(1)
                        .padding(.bottom, 100)
                        .onAppear {
                            // Bounce up
                            withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
                                popupOffset = 0
                            }
                            // Fade out after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showCatchSavedPopup = false
                                    popupOffset = 150
                                    user.speciesStore.popupType = 0
                                }
                            }
                        }
                    }
                }
            }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear { startCleanTimer() }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
            bottomBarWorkItem?.cancel()
            stopBubbleSound()
        }
   
        .onReceive(user.speciesStore.$popupType) { newValue in
            guard newValue > 0 else { return }
            var message = ""
            var color: Color = .cyan
            switch newValue {
            case 1:
                message = "Fish Caught!"
                color = .cyan
            case 2:
                message = "New Species Caught!"
                color = .cyan
            case 3:
                message = "Catch of the Week!"
                color = Color(red: 1.0, green: 0.84, blue: 0.0) 
            default: break
            }
            triggerCatchPopup(message: message, color: color)
        }
       
        .onChange(of: tabRouter.viewState) { oldState, newState in
            if newState == .aquarium {
                lastUpdate = Date()
                user.aquariumState.commitPendingClean()
                if user.aquariumState.bubbleAmount > 0 { startBubbleSound() }
            } else { stopBubbleSound() }
        }
        .onReceive(user.aquariumState.$bubbleAmount) { newValue in
            updateBubbleVolume()
            if tabRouter.viewState == .aquarium {
                if newValue > 0 && bubblePlayer == nil { startBubbleSound() }
            } else { stopBubbleSound() }
        }
    }
   
    private func triggerCatchPopup(message: String, color: Color) {
        popupOffset = 150
        catchSavedMessage = message
        popupColor = color
        showCatchSavedPopup = true
    }

    private func customTabIcon(systemImage: String, tab: ViewState) -> some View {
        Button(action: { tabRouter.viewState = tab; if tab == .aquarium { resetBottomBarTimer() } }) {
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
        Button(action: { tabRouter.viewState = tab; if tab == .aquarium { resetBottomBarTimer() } }) {
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


    private func startCleanTimer() {
        cleanTimer?.invalidate()
        let totalDuration: TimeInterval = 60 * 60
        let tickInterval: TimeInterval = 5
        lastUpdate = Date()
        
        cleanTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(self.lastUpdate)
            self.lastUpdate = now

            if user.aquariumState.isActiveScreen {
                let increment = user.aquariumState.maxClean / totalDuration * delta
                user.aquariumState.updateClean(by: increment)
            } else {
                let increment = user.aquariumState.maxClean / totalDuration * delta
                user.aquariumState.updatePendingClean(
                    to: min(user.aquariumState.pendingClean + increment, user.aquariumState.maxClean)
                )
            }
        }
    }

  
    func resetBottomBarTimer() {
        bottomBarWorkItem?.cancel()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { showAquariumBottomBar = true }
        let workItem = DispatchWorkItem {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { showAquariumBottomBar = false }
        }
        bottomBarWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }

 
    private func startBubbleSound() {
        guard bubblePlayer == nil else { return }
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
        let scaledVolume = Float(user.aquariumState.bubbleAmount) * 0.5
        player.volume = scaledVolume
    }
}

#Preview {
    HomerView()
        .environmentObject(User())
        .environmentObject(LeaderboardData())
}

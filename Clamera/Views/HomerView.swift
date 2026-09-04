//
//  HomerView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/4/26.
//

import SwiftUI
import FirebaseFirestore

enum ViewState {
    case home, aquarium, profile, caught, album, social, settings
}

final class TabRouter: ObservableObject {
    @Published var viewState: ViewState = .home
    @Published var albumTargetSpecies: String? = nil
}

struct ReceivedGift: Identifiable {
    let id: String
    let senderUsername: String
    let amount: Int
}

struct HomerView: View {
    @EnvironmentObject var user: User
    @StateObject private var tabRouter = TabRouter()
    @State private var cleanTimer: Timer?
    @State private var lastUpdate: Date = Date()
    
    // Popup States
    @State private var showCatchSavedPopup: Bool = false
    @State private var catchSavedTitle: String = ""
    @State private var catchSavedSubtitle: String = ""
    @State private var popupFishName: String = ""
    @State private var popupColor: Color = .cyan
    @State private var popupOffset: CGFloat = 200
    
    @State private var showAquariumBottomBar: Bool = true
    @State private var bottomBarWorkItem: DispatchWorkItem?

    // Real-Time Gifting States
    @State private var receivedGift: ReceivedGift?
    @State private var giftListener: ListenerRegistration?

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
                        }
                    }
                case .social: NavigationStack { SocialView() }
                default: NavigationStack { HomeRevised() }
                }
            }
            .environmentObject(tabRouter)
            .environmentObject(user)

            // MARK: - Tab Bar
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

            // MARK: - Catch Celebration Popup
            VStack {
                Spacer()
                
                if showCatchSavedPopup {
                    HStack(spacing: 14) {
                        Image("\(popupFishName)Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.1), radius: 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(catchSavedTitle)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(catchSavedSubtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showCatchSavedPopup = false
                                popupOffset = 200
                                user.speciesStore.popupType = 0
                            }
                            tabRouter.albumTargetSpecies = popupFishName
                            tabRouter.viewState = .album
                        } label: {
                            Text("View")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(popupColor)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.08), radius: 3)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 440))
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [popupColor, popupColor.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: popupColor.opacity(0.4), radius: 12, y: 6)
                    )
                    .offset(y: popupOffset)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(10)
                    .padding(.bottom, 105)
                    .onAppear {
                        withAnimation(.interpolatingSpring(stiffness: 190, damping: 17)) {
                            popupOffset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCatchSavedPopup = false
                                popupOffset = 200
                                user.speciesStore.popupType = 0
                            }
                        }
                    }
                }
            }

            // MARK: - Real-Time Received Gift Popup
            if let gift = receivedGift {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 74, height: 74)

                            Image(systemName: "gift.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 8)

                        Text("\(gift.senderUsername) sent you a gift!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)

                        HStack(spacing: 6) {
                            Text("+\(gift.amount)")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.cyan)
                            Text("Clam Points")
                                .font(.headline.bold())
                                .foregroundColor(.secondary)
                        }

                        Button {
                            dismissGift(gift)
                        } label: {
                            Text("Awesome!")
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(Color.cyan)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 4)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
                    .padding(.horizontal, 40)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                    .zIndex(20)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: receivedGift != nil)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            startCleanTimer()
            listenForIncomingGifts()
        }
        .onDisappear {
            cleanTimer?.invalidate()
            cleanTimer = nil
            bottomBarWorkItem?.cancel()
            giftListener?.remove()
            giftListener = nil
        }
        .onReceive(user.speciesStore.$popupType) { newValue in
            guard newValue > 0 else { return }
            
            let fishName = user.speciesStore.lastCaughtFishName.isEmpty
                ? "Fish"
                : user.speciesStore.lastCaughtFishName
            
            popupFishName = fishName
            
            switch newValue {
            case 1:
                catchSavedTitle = "Fish Caught!"
                catchSavedSubtitle = "\(fishName) added to your album"
                popupColor = .cyan
            case 2:
                catchSavedTitle = "New Species Unlocked!"
                catchSavedSubtitle = "+50 Bonus Clam Points earned!"
                popupColor = Color.purple
            case 3:
                catchSavedTitle = "Catch of the Week!"
                catchSavedSubtitle = "Maximum Clam Points awarded!"
                popupColor = Color(red: 1.0, green: 0.78, blue: 0.1)
            default: break
            }
            
            triggerCatchPopup()
        }
        .onChange(of: tabRouter.viewState) { _, newState in
            if newState == .aquarium {
                lastUpdate = Date()
                user.aquariumState.commitPendingClean()
            }
        }
    }
    
    private func listenForIncomingGifts() {
        guard !user.id.isEmpty else { return }
        giftListener?.remove()

        giftListener = Firestore.firestore()
            .collection("users")
            .document(user.id)
            .collection("pendingGifts")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, !documents.isEmpty else { return }

                if let doc = documents.first {
                    let data = doc.data()
                    let sender = data["senderUsername"] as? String ?? "A Friend"
                    let amount = data["amount"] as? Int ?? 0

                    // Explicitly run point increment & UI trigger on the main actor
                    DispatchQueue.main.async {
                        self.user.objectWillChange.send()
                        self.user.speciesStore.objectWillChange.send()
                        self.user.speciesStore.totalClamPoints += amount

                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            self.receivedGift = ReceivedGift(
                                id: doc.documentID,
                                senderUsername: sender,
                                amount: amount
                            )
                        }
                    }
                }
            }
    }

    private func dismissGift(_ gift: ReceivedGift) {
        withAnimation {
            receivedGift = nil
        }

        Task {
            // Save updated balance to the recipient's document
            await FirestoreManager.shared.saveUser(user: user)

            // Delete claimed gift from pendingGifts
            try? await Firestore.firestore()
                .collection("users")
                .document(user.id)
                .collection("pendingGifts")
                .document(gift.id)
                .delete()
        }
    }
    
    private func triggerCatchPopup() {
        popupOffset = 200
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
}

#Preview {
    HomerView()
        .environmentObject(User())
}

//
//  AquariumManageView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct AquariumManageView: View {
    @EnvironmentObject var user: User
    
    @State private var selectedFishIndex: Int? = nil
    @State private var refreshID = UUID()
    @State private var showClearConfirm = false
    @State private var fishToRemove: AquariumFish? = nil
    @State private var saveDebounceWorkItem: DispatchWorkItem? = nil

    private let maxCardWidth: CGFloat = 540

    private func scheduleSave() {
        saveDebounceWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            Task {
                if let authUser = AuthManager.shared.user {
                    await FirestoreManager.shared.saveUser(user: authUser)
                }
            }
        }
        saveDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }

    private func removeFish(_ fish: AquariumFish) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if let speciesID = fish.speciesID,
               let species = user.speciesStore.speciesList.first(where: { $0.id == speciesID }) {
                if let fishRecord = species.fishList.first(where: { $0.isAquarium }) {
                    fishRecord.isAquarium = false
                }
            }
            user.aquarium.removeFish(with: fish.imageName, targetSize: fish.size)
            selectedFishIndex = nil
        }
        scheduleSave()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Header Info Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 16) {
                        Image("aquariumSetting")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .background(Color.cyan.opacity(0.15))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.06), radius: 4)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Aquarium")
                                .font(.title2.bold())
                                .foregroundColor(.primary)

                            Text("Personalize fish, bubbles, and filter settings")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(20)
                .frame(maxWidth: maxCardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // MARK: - Fish Manager Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Fish")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Tap row to configure • Tap 🗑 to remove")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 12) {
                        ForEach(Array(user.aquarium.fish.enumerated()), id: \.element.id) { index, fish in
                            VStack(spacing: 0) {
                                HStack(spacing: 14) {
                                    if fish.isActive {
                                        Image(fish.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 44, height: 44)
                                            .opacity(fish.isShown ? 1.0 : 0.4)

                                        Button {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                if selectedFishIndex == index {
                                                    selectedFishIndex = nil
                                                } else {
                                                    selectedFishIndex = index
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text("Controls")
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.primary)
                                                Image(systemName: "chevron.down")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.secondary)
                                                    .rotationEffect(.degrees(selectedFishIndex == index ? 180 : 0))
                                            }
                                            .padding(.vertical, 7)
                                            .padding(.horizontal, 0)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(.plain)

                                        Spacer()

                                        // Explicit Remove Button
                                        Button {
                                            fishToRemove = fish
                                        } label: {
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red.opacity(0.85))
                                                .padding(9)
                                                .background(Color.red.opacity(0.12))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)

                                        // Visibility Toggle
                                        Toggle("", isOn: $user.aquarium.fish[index].isShown)
                                            .labelsHidden()
                                            .tint(.green)
                                            .onChange(of: user.aquarium.fish[index].isShown) { _, _ in
                                                scheduleSave()
                                            }

                                    } else {
                                        Image("FishIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 44, height: 44)
                                            .opacity(0.3)
                                            .scaleEffect(x: -1, y: 1)

                                        Text("Empty Slot")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Spacer()
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)

                                // Expanded Speed & Size Adjustments
                                if fish.isActive && selectedFishIndex == index {
                                    VStack(spacing: 16) {
                                        Divider()
                                            .padding(.vertical, 4)

                                        // Swim Speed Slider
                                        HStack(spacing: 12) {
                                            Image("slow")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)

                                            Slider(
                                                value: Binding(
                                                    get: { 16 - fish.swimDuration },
                                                    set: { newVal in
                                                        user.aquarium.updateSpeed(for: fish, to: 16 - newVal)
                                                        scheduleSave()
                                                    }
                                                ),
                                                in: 1...15
                                            )
                                            .tint(.cyan)

                                            Image("fast")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                        }

                                        // Fish Size Slider
                                        HStack(spacing: 12) {
                                            Image("small")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)

                                            Slider(
                                                value: Binding(
                                                    get: { Double(fish.size.width) },
                                                    set: { newVal in
                                                        let newHeight = fish.size.height * newVal / fish.size.width
                                                        user.aquarium.updateSize(for: fish, to: CGSize(width: newVal, height: newHeight))
                                                        scheduleSave()
                                                    }
                                                ),
                                                in: 20...200
                                            )
                                            .tint(.cyan)

                                            Image("big")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 14)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .background(Color(.systemGray6).opacity(0.6))
                            .cornerRadius(18)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: maxCardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                .padding(.horizontal, 16)

                // MARK: - Filter Status Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Filter")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    VStack(spacing: 12) {
                        HStack(spacing: 14) {
                            let cleanPercent = 100 - (300 * user.aquariumState.clean)
                            if cleanPercent > 60 {
                                Image("good")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            } else if cleanPercent > 20 {
                                Image("med")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            } else {
                                Image("bad")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            }

                            Text("Status")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Text("\(String(format: "%.2f", cleanPercent))%")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        HStack(spacing: 14) {
                            Image("level")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)

                            Text("Level")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Text("4")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6).opacity(0.6))
                    .cornerRadius(18)
                }
                .padding(20)
                .frame(maxWidth: maxCardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                .padding(.horizontal, 16)

                // MARK: - Bubbles Controls Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Bubbles")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { user.aquariumState.bubbleVisibility > 0 },
                            set: { newValue in
                                user.aquariumState.bubbleVisibility = newValue ? 1.0 : 0.0
                                user.aquariumState.bubbleAmount = newValue ? 1.0 : 0.0
                                scheduleSave()
                            }
                        ))
                        .labelsHidden()
                        .tint(.green)
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image("bubbleIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .cornerRadius(8)

                            Text("Amount: \(String(format: "%.1f", user.aquariumState.bubbleAmount))")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)

                            Spacer()

                            Stepper("", value: $user.aquariumState.bubbleAmount, in: 0.1...3.0, step: 0.1)
                                .labelsHidden()
                                .onChange(of: user.aquariumState.bubbleAmount) { _, _ in
                                    scheduleSave()
                                }
                        }

                        Divider()

                        HStack(spacing: 12) {
                            Image("visibility")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .colorInvert()
                                .cornerRadius(8)

                            Text("Visibility: \(String(format: "%.1f", user.aquariumState.bubbleVisibility))")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)

                            Spacer()

                            Stepper("", value: $user.aquariumState.bubbleVisibility, in: 0.1...2.0, step: 0.1)
                                .labelsHidden()
                                .onChange(of: user.aquariumState.bubbleVisibility) { _, _ in
                                    scheduleSave()
                                }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6).opacity(0.6))
                    .cornerRadius(18)
                }
                .padding(20)
                .frame(maxWidth: maxCardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                .padding(.horizontal, 16)

                // MARK: - Clear Aquarium Button
                Button {
                    showClearConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Aquarium")
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: maxCardWidth)
                    .frame(height: 56)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                .confirmationDialog("Clear all fish from the aquarium?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                    Button("Clear All", role: .destructive) {
                        user.aquarium.toggleAll()
                        refreshID = UUID()
                        scheduleSave()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "Remove this fish from your aquarium?",
            isPresented: Binding(
                get: { fishToRemove != nil },
                set: { if !$0 { fishToRemove = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                if let targetFish = fishToRemove {
                    removeFish(targetFish)
                }
                fishToRemove = nil
            }
            Button("Cancel", role: .cancel) {
                fishToRemove = nil
            }
        }
        .onAppear {
            user.aquariumState.markActive("manage")
        }
        .onDisappear {
            saveDebounceWorkItem?.cancel()
            Task {
                if let authUser = AuthManager.shared.user {
                    await FirestoreManager.shared.saveUser(user: authUser)
                }
            }
            user.aquariumState.updatePendingClean(to: user.aquariumState.clean)
            user.aquariumState.markInactive("manage")
        }
    }
}

#Preview {
    AquariumManageView()
        .environmentObject(User())
}

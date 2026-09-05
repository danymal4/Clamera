//
//  ShopItemDetailsView.swift
//  Clamera
//
//  Created by Kaes van Dolder on 2026-08.
//

import SwiftUI

struct ShopItemDetailsView: View {
    let item: ShopItem
    @EnvironmentObject var user: User
    @Environment(\.dismiss) var dismiss
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isProcessing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // Big Icon Showcase
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.45), Color.blue.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .frame(height: 280)
                    
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)
                }
                .padding(.horizontal, 20)
                
                // Item Name & Ownership Status
                VStack(spacing: 8) {
                    Text(cleanItemName)
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    if user.unlockedShopItems.contains(item.id) {
                        Text("Already Unlocked")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.12))
                            .cornerRadius(10)
                    }
                }
                
                // Purchase Buttons Section
                VStack(spacing: 16) {
                    let standardCost = calculateCost(isDailyDiscount: false)
                    
                    // Standard Buy Button
                    Button(action: { handlePurchase(isDailyDiscount: false) }) {
                        HStack {
                            Text("Buy Item")
                                .bold()
                            Spacer()
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("\(standardCost) Clam Points")
                                    .bold()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(user.unlockedShopItems.contains(item.id) ? Color.gray : Color.blue)
                        .cornerRadius(16)
                    }
                    .disabled(user.unlockedShopItems.contains(item.id) || isProcessing)
                    
                    // Daily Discount Buy Button (Once Per Day)
                    let discountCost = calculateCost(isDailyDiscount: true)
                    let alreadyUsedToday = hasUsedDailyDiscountToday()
                    let isLocked = user.unlockedShopItems.contains(item.id) || alreadyUsedToday || isProcessing
                    
                    Button(action: { handlePurchase(isDailyDiscount: true) }) {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Buy with Daily Discount")
                                    .bold()
                                Spacer()
                                if isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("\(discountCost) Clam Points")
                                        .bold()
                                }
                            }
                            
                            HStack {
                                Text(alreadyUsedToday ? "Already used today" : String(format: "%.0f%% off (Once per day)", user.shopDiscountPercentage))
                                    .font(.caption2)
                                    .opacity(0.8)
                                Spacer()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Group {
                                if isLocked {
                                    Color.gray
                                } else {
                                    LinearGradient(colors: [Color.purple, Color.indigo], startPoint: .leading, endPoint: .trailing)
                                }
                            }
                        )
                        .cornerRadius(16)
                    }
                    .disabled(isLocked)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle(cleanItemName)
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var cleanItemName: String {
        item.name.replacingOccurrences(of: " Icon", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func calculateCost(isDailyDiscount: Bool) -> Int {
        if isDailyDiscount {
            let discountMultiplier = 1.0 - (user.shopDiscountPercentage / 100.0)
            let discountedCost = Double(item.baseCost) * discountMultiplier
            return max(0, Int(discountedCost))
        } else {
            return item.baseCost
        }
    }
    
    private func hasUsedDailyDiscountToday() -> Bool {
        guard let lastDate = user.lastDailyDiscountDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    private func handlePurchase(isDailyDiscount: Bool) {
        let cost = calculateCost(isDailyDiscount: isDailyDiscount)
        
        guard user.speciesStore.totalClamPoints >= cost else {
            alertTitle = "Insufficient Clam Points"
            alertMessage = "You need \(cost) Clam Points, but you only have \(user.speciesStore.totalClamPoints)."
            showAlert = true
            return
        }
        
        isProcessing = true
        
        // 1. Deduct points and register unlocked item
        user.speciesStore.totalClamPoints -= cost
        user.unlockedShopItems.insert(item.id)
        
        if isDailyDiscount {
            user.lastDailyDiscountDate = Date()
        }
        
        // 2. Add fish to user's album if matching species exists
        addPurchasedFishToAlbum()
        
        // 3. Persist modifications directly to Firestore
        Task {
            await FirestoreManager.shared.saveUser(user: user)
            
            await MainActor.run {
                isProcessing = false
                alertTitle = "Success!"
                alertMessage = "You've successfully unlocked the \(cleanItemName)!"
                showAlert = true
            }
        }
    }
    
    private func addPurchasedFishToAlbum() {
        let nameToMatch = cleanItemName.lowercased()
        
        for index in 0..<user.speciesStore.speciesList.count {
            let currentSpecies = user.speciesStore.speciesList[index]
            if currentSpecies.name.lowercased() == nameToMatch {
                // Check if already in album to prevent duplicate catch entries
                let alreadyInAlbum = currentSpecies.fishList.contains { $0.photo == item.iconName }
                if !alreadyInAlbum {
                    let newFish = Fish(
                        photo: item.iconName,
                        speciesName: currentSpecies.name,
                        description: "Purchased from Shop",
                        dateCaught: Date(),
                        isPinned: false,
                        isPurchased: true
                    )
                    user.speciesStore.speciesList[index].fishList.append(newFish)
                }
                break
            }
        }
    }
}

#Preview {
    NavigationView {
        ShopItemDetailsView(
            item: ShopItem(
                id: "walleye_cosmetic",
                name: "Walleye Icon",
                iconName: "WalleyeIcon",
                baseCost: 350,
                category: .all
            )
        )
        .environmentObject(User())
    }
}

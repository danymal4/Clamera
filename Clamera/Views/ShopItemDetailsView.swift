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
                    Text(item.name.replacingOccurrences(of: " Icon", with: ""))
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
                            Text("\(standardCost) pts")
                                .bold()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(user.unlockedShopItems.contains(item.id) ? Color.gray : Color.blue)
                        .cornerRadius(16)
                    }
                    .disabled(user.unlockedShopItems.contains(item.id))
                    
                    // Daily Discount Buy Button (Once Per Day)
                    let discountCost = calculateCost(isDailyDiscount: true)
                    let alreadyUsedToday = hasUsedDailyDiscountToday()
                    let isLocked = user.unlockedShopItems.contains(item.id) || alreadyUsedToday
                    
                    Button(action: { handlePurchase(isDailyDiscount: true) }) {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Buy with Daily Discount")
                                    .bold()
                                Spacer()
                                Text("\(discountCost) pts")
                                    .bold()
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
        .navigationTitle(item.name.replacingOccurrences(of: " Icon", with: ""))
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
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
        
        if user.speciesStore.totalClamPoints >= cost {
            user.speciesStore.totalClamPoints -= cost
            user.unlockedShopItems.insert(item.id)
            
            if isDailyDiscount {
                user.lastDailyDiscountDate = Date()
            }
            
            alertTitle = "Success!"
            alertMessage = "You've successfully unlocked the \(item.name.replacingOccurrences(of: " Icon", with: ""))!"
        } else {
            alertTitle = "Insufficient Clam Points"
            alertMessage = "You need \(cost) points, but you only have \(user.speciesStore.totalClamPoints)."
        }
        showAlert = true
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

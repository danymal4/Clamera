//
//  ShopView.swift
//  Clamera
//
//  Created by Kaes van Dolder on 2026-08.

import SwiftUI

// MARK: - Shop Structural Types
struct ShopItem: Identifiable, Equatable {
    let id: String
    let name: String
    let iconName: String
    let baseCost: Int
    let category: ShopCategory
}

enum ShopCategory: String, CaseIterable {
    case all = "All"
    case icons = "Icons"
    case boosts = "Boosts"
    case points = "Earn Points"
}

// MARK: - Main Shop View
struct ShopView: View {
    private let ui = UIScreen.main.bounds
    @State private var floatUpDown = false
    @EnvironmentObject var user: User
    @StateObject private var adManager = RewardedAdManager()
    
    // Alert state handling for purchases & rewards
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Category state tracking
    @State private var selectedCategory: ShopCategory = .all
    
    private var completeCatalog: [ShopItem] { ShopCatalog.items }
    
    private var dailyItems: (saleItem: ShopItem, regularItems: [ShopItem]) {
        guard !completeCatalog.isEmpty else {
            let defaultItem = ShopItem(id: "fallback", name: "Walleye Icon", iconName: "WalleyeIcon", baseCost: 350, category: .icons)
            return (defaultItem, [])
        }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let saleIndex = dayOfYear % completeCatalog.count
        
        let sale = completeCatalog[saleIndex]
        let remaining = completeCatalog.filter { $0.id != sale.id }
        
        return (sale, remaining)
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        let rotation = dailyItems
        let saleItem = rotation.saleItem
        
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Header Bar
                    HStack {
                        (
                            Text("Happy Shopping ")
                                .font(.title2)
                                .fontWeight(.semibold)
                            +
                            Text(user.username.lowercased())
                                .font(.title2)
                                .fontWeight(.bold)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.black.opacity(0.75), Color.cyan.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image("clamIcon")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18)
                                .scaleEffect(1.3)
                            
                            Text("\(user.speciesStore.totalClamPoints)")
                                .bold()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // MARK: - Login Streak Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.55), Color.indigo.opacity(0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .frame(height: 64)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Login Streak: \(user.loginStreak) Days")
                                    .bold()
                                    .foregroundColor(.white)
                                Text(String(format: "Shop Discount: %.0f%%", user.shopDiscountPercentage))
                                    .bold()
                                    .foregroundColor(.white)
                                    .font(.footnote)
                            }
                            Spacer()
                            Image(systemName: "flame.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Category Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ShopCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    withAnimation(.snappy) {
                                        selectedCategory = category
                                    }
                                }) {
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                        .bold()
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.cyan : Color.black.opacity(0.05))
                                        .foregroundColor(selectedCategory == category ? .white : .secondary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Dynamic Content Based on Selected Tab
                    if selectedCategory == .points {
                        // Rewarded Video Ad Option for Free Clam Points
                        VStack(spacing: 16) {
                            Text("Free Clam Points")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                adManager.showAd {
                                    user.speciesStore.totalClamPoints += 50
                                    alertTitle = "Clam Points Earned!"
                                    alertMessage = "You earned +50 Clam Points for watching an ad!"
                                    showAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("Watch Ad for Clams")
                                            .bold()
                                        Text(adManager.adLoaded ? "Earn +50 Clam Points instantly" : "Loading video ad...")
                                            .font(.caption)
                                            .opacity(0.8)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: adManager.adLoaded ? [Color.cyan, Color.blue] : [Color.gray, Color.gray.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            .disabled(!adManager.adLoaded)
                        }
                        .padding(.horizontal, 20)
                        
                    } else {
                        
                        // Sale of the Day card (only rendered on the All tab)
                        if selectedCategory == .all {
                            Button(action: { handlePurchase(item: saleItem, isSaleItem: true) }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(LinearGradient(colors: [Color.blue.opacity(0.45), Color.blue.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                    
                                    VStack {
                                        Spacer()
                                        Image(saleItem.iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: ui.width * 0.45, height: ui.width * 0.45)
                                            .offset(y: floatUpDown ? -6 : 6)
                                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: floatUpDown)
                                        Spacer()
                                        Text("Sale of the Day").bold().foregroundColor(.white)
                                        HStack {
                                            Text(saleItem.name.replacingOccurrences(of: " Icon", with: "")).bold().foregroundColor(.white)
                                            Spacer()
                                            Text(user.unlockedShopItems.contains(saleItem.id) ? "Unlocked" : "Cost: \(calculateCost(for: saleItem, isSaleItem: true)) pts")
                                                .bold().foregroundColor(.white).padding(6).background(Color.black.opacity(0.25)).cornerRadius(10)
                                        }
                                        .padding(16)
                                    }
                                }
                                .frame(height: ui.width * 0.75)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.horizontal, 20)
                        }
                        
                        let filteredItems = selectedCategory == .all
                            ? rotation.regularItems
                            : rotation.regularItems.filter { $0.category == selectedCategory }
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems) { item in
                                Button(action: { handlePurchase(item: item, isSaleItem: false) }) {
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(LinearGradient(colors: [Color.cyan.opacity(0.45), Color.blue.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                        
                                        VStack(spacing: 8) {
                                            Spacer()
                                            Image(item.iconName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 55)
                                                .offset(y: floatUpDown ? -2 : 4)
                                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: floatUpDown)
                                            Spacer()
                                            Text(item.name.replacingOccurrences(of: " Icon", with: ""))
                                            Text(user.unlockedShopItems.contains(item.id) ? "Unlocked" : "\(calculateCost(for: item, isSaleItem: false)) pts")
                                                .font(.caption).bold().foregroundColor(.white)
                                                .padding(.horizontal, 8).padding(.vertical, 4)
                                                .background(Color.black.opacity(0.25)).cornerRadius(8)
                                                .padding(.bottom, 12)
                                        }
                                    }
                                    .frame(height: ui.width * 0.38)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 140)
                }
            }
            
            // Bottom Tab Bar Mask Layer
            Rectangle()
                .fill(Color.white)
                .overlay(Color.blue.opacity(0.06))
                .frame(height: ui.height * 0.112)
                .shadow(color: .black.opacity(0.1), radius: 10)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(
            ZStack {
                Color.blue.opacity(0.08).edgesIgnoringSafeArea(.all)
                WaterView().opacity(0.3)
            }
        )
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            floatUpDown = true
            user.checkLoginStreak()
        }
    }
    
    private func calculateCost(for item: ShopItem, isSaleItem: Bool) -> Int {
        let discountMultiplier = 1.0 - (user.shopDiscountPercentage / 100.0)
        let intermediateCost = Double(item.baseCost) * discountMultiplier
        let finalCost = isSaleItem ? (intermediateCost * 0.85) : intermediateCost
        return Int(finalCost)
    }
    
    private func handlePurchase(item: ShopItem, isSaleItem: Bool) {
        if user.unlockedShopItems.contains(item.id) {
            alertTitle = "Already Owned"
            alertMessage = "You have already unlocked the \(item.name)!"
            showAlert = true
            return
        }
        
        let preciseCost = calculateCost(for: item, isSaleItem: isSaleItem)
        
        if user.speciesStore.totalClamPoints >= preciseCost {
            user.speciesStore.totalClamPoints -= preciseCost
            user.unlockedShopItems.insert(item.id)
            
            alertTitle = "Success!"
            alertMessage = "You've unlocked the \(item.name) for \(preciseCost) Clam Points!"
        } else {
            alertTitle = "Insufficient Clam Points"
            alertMessage = "You need \(preciseCost) points, but you only have \(user.speciesStore.totalClamPoints)."
        }
        showAlert = true
    }
}

// Custom button scale effect style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Canvas Preview
#Preview {
    ShopView()
        .environmentObject(User())
}

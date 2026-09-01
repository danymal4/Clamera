//
//  ShopView.swift
//  Clamera
//
//  Created by Kaes van Dolder on 2026-08.
//

import SwiftUI

struct ShopView: View {
    private let ui = UIScreen.main.bounds
    @State private var floatUpDown = false
    @EnvironmentObject var user: User
    @StateObject private var adManager = RewardedAdManager()
    
    // Category state tracking (including earnPoints tab)
    enum ShopTab: Equatable {
        case category(ShopCategory)
        case earnPoints
    }
    
    @State private var selectedTab: ShopTab = .category(.all)
    
    private var completeCatalog: [ShopItem] { ShopCatalog.items }
    
    private var dailyItems: (saleItem: ShopItem, regularItems: [ShopItem]) {
        guard !completeCatalog.isEmpty else {
            let defaultItem = ShopItem(id: "fallback", name: "Walleye Icon",
                                       iconName: "WalleyeIcon", baseCost: 350, category: .all)
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
        NavigationView {
            let rotation = dailyItems
            let saleItem = rotation.saleItem
            let regularItems = rotation.regularItems
            
            let filteredItems: [ShopItem] = {
                switch selectedTab {
                case .category(let cat):
                    return cat == .all ? regularItems : regularItems.filter { $0.category == cat }
                case .earnPoints:
                    return []
                }
            }()
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header / Streak Info Banner
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Login Streak: \(user.loginStreak) Days")
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                            }
                            Text("Shop Discount: \(Int(user.shopDiscountPercentage))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        
                        // Category & Bold Highlighted Earn Points Tab Selectors (Cool Blue-Purple Tint)
                        HStack(spacing: 12) {
                            Button("All") { selectedTab = .category(.all) }
                                .buttonStyle(.borderedProminent)
                                .tint(selectedTab == .category(.all) ? .blue : .gray.opacity(0.2))
                            
                            Button(action: { selectedTab = .earnPoints }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                    Text("Earn Points")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(selectedTab == .earnPoints ? Color(red: 0.3, green: 0.3, blue: 0.9) : Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.25))
                            .foregroundColor(selectedTab == .earnPoints ? .white : Color(red: 0.3, green: 0.3, blue: 0.9))
                            .bold()
                        }
                        .padding(.horizontal, 20)
                        
                        if case .earnPoints = selectedTab {
                            // Earn Points Horizontal Banner with Cool Blue-Purple Gradient
                            Button(action: {
                                adManager.showAd {
                                    Task { @MainActor in
                                        user.speciesStore.totalClamPoints += 50
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(LinearGradient(colors: [Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.45), Color.blue.opacity(0.30)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.2), lineWidth: 1))
                                    
                                    HStack(spacing: 12) {
                                        // Left Side: Text details
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Free Bonus")
                                                .font(.caption.bold())
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(red: 0.3, green: 0.3, blue: 0.9))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                            
                                            Text("Earn 50 Points")
                                                .font(.title2.bold())
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                            
                                            Text("Watch Ad")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Right Side: Cinema Vibes Play Icon
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.25))
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.9))
                                        }
                                    }
                                    .padding(20)
                                }
                                .frame(height: 160)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            
                        } else {
                            // Sale of the Day Banner (Responsive Layout)
                            NavigationLink(destination: ShopItemDetailsView(item: saleItem)) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.45), Color.blue.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                    
                                    HStack(spacing: 12) {
                                        // Left Side: Text details
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Sale of the Day")
                                                .font(.caption.bold())
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                            
                                            Text(saleItem.name.replacingOccurrences(of: " Icon", with: ""))
                                                .font(.title2.bold())
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                            
                                            Text("Cost: \(Int(Double(saleItem.baseCost) * 0.8)) pts")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Right Side: Scaled Image that fits any device safely
                                        Image(saleItem.iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 110)
                                    }
                                    .padding(20)
                                }
                                .frame(height: 160)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            
                            // Grid Items
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredItems) { item in
                                    NavigationLink(destination: ShopItemDetailsView(item: item)) {
                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(LinearGradient(colors: [Color.cyan.opacity(0.45), Color.blue.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                             
                                            VStack(spacing: 8) {
                                                Spacer()
                                                ZStack {
                                                    Image(item.iconName)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 75)
                                                }
                                                .offset(y: floatUpDown ? -2 : 4)
                                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: floatUpDown)
                                                
                                                Spacer()
                                                
                                                Text(item.name.replacingOccurrences(of: " Icon", with: ""))
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundColor(.primary)
                                                
                                                Text(user.unlockedShopItems.contains(item.id) ? "Unlocked" : "\(item.baseCost) pts")
                                                    .font(.caption).bold().foregroundColor(.white)
                                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                                    .background(Color.black.opacity(0.25)).cornerRadius(8)
                                                    .padding(.bottom, 12)
                                            }
                                        }
                                        .frame(height: ui.width * 0.45)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 10)
                }
                
                // WaterView anchored cleanly at the bottom edge if Earn Points tab is active
                if case .earnPoints = selectedTab {
                    WaterView()
                        .frame(height: 180)
                        .opacity(0.5)
                        .ignoresSafeArea(edges: .bottom)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Shop")
            .onAppear {
                floatUpDown = true
                user.checkLoginStreak()
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Canvas Preview
#Preview {
    ShopView()
        .environmentObject(User())
}

//
//  ShopView.swift
//  Clamera
//
//  Created by Dany Malaeb on 2026-08.
//

import SwiftUI

enum ShopSortOption: String, CaseIterable, Identifiable {
    case alphabetical = "A-Z"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    var id: String { self.rawValue }
}

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
    
    @State private var selectedTab: ShopTab
    @State private var searchText = ""
    @State private var selectedSort: ShopSortOption = .alphabetical
    @FocusState private var isSearchFieldFocused: Bool

    init(initialTab: ShopTab = .category(.all)) {
        _selectedTab = State(initialValue: initialTab)
    }

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
             
            let baseFilteredItems: [ShopItem] = {
                switch selectedTab {
                case .category(let cat):
                    return cat == .all ? regularItems : regularItems.filter { $0.category == cat }
                case .earnPoints:
                    return []
                }
            }()
             
            let searchedItems = baseFilteredItems.filter { item in
                if searchText.isEmpty { return true }
                return item.name.localizedStandardContains(searchText)
            }
             
            let filteredItems = searchedItems.sorted { item1, item2 in
                switch selectedSort {
                case .alphabetical:
                    return item1.name < item2.name
                case .priceLowToHigh:
                    return item1.baseCost < item2.baseCost
                case .priceHighToLow:
                    return item1.baseCost > item2.baseCost
                }
            }
             
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
                         
                        // Category & Earn Points Tab Selectors + Sort Menu
                        HStack(spacing: 12) {
                            Button("All") { selectedTab = .category(.all) }
                                .buttonStyle(.borderedProminent)
                                .tint(selectedTab == .category(.all) ? .blue : .gray.opacity(0.2))
                             
                            Button(action: { selectedTab = .earnPoints }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                    Text("Earn Clam Points")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(selectedTab == .earnPoints ? Color(red: 0.3, green: 0.3, blue: 0.9) : Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.25))
                            .foregroundColor(selectedTab == .earnPoints ? .white : Color(red: 0.3, green: 0.3, blue: 0.9))
                            .bold()
                            .overlay(
                                Capsule().stroke(Color(red: 1.0, green: 0.84, blue: 0.0), lineWidth: 2)
                            )
                             
                            Spacer()
                             
                            // Sort Menu
                            Menu {
                                Picker("Sort By", selection: $selectedSort) {
                                    ForEach(ShopSortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(selectedSort.rawValue)
                                        .lineLimit(1)
                                }
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Custom Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search fish and items...", text: $searchText)
                                .textFieldStyle(.plain)
                                .focused($isSearchFieldFocused)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                         
                        if case .earnPoints = selectedTab {
                            // Earn Clam Points Horizontal Banner
                            Button(action: {
                                adManager.showAd {
                                    Task { @MainActor in
                                        user.objectWillChange.send()
                                        user.speciesStore.objectWillChange.send()
                                        user.speciesStore.totalClamPoints += 100
                                        await FirestoreManager.shared.saveUser(user: user)
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(LinearGradient(colors: [Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.45), Color.blue.opacity(0.30)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.2), lineWidth: 1))
                                    
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Free Bonus")
                                                .font(.caption.bold())
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(red: 0.3, green: 0.3, blue: 0.9))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                            
                                            Text("Earn 100 Clam Points")
                                                .font(.title2.bold())
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                            
                                            Text(adManager.rewardedAd == nil ? "Loading ad..." : "Watch Ad")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.25))
                                                .frame(width: 70, height: 70)
                                            
                                            if adManager.rewardedAd == nil || adManager.isProcessingAdRequest {
                                                ProgressView()
                                                    .tint(Color(red: 0.3, green: 0.3, blue: 0.9))
                                            } else {
                                                Image(systemName: "play.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.9))
                                            }
                                        }
                                    }
                                    .padding(20)
                                }
                                .frame(height: 160)
                                .opacity((adManager.rewardedAd == nil || adManager.isProcessingAdRequest) ? 0.6 : 1.0)
                            }
                            .buttonStyle(.plain)
                            .disabled(adManager.rewardedAd == nil || adManager.isProcessingAdRequest)
                            .padding(.horizontal, 20)
                             
                        } else {
                            // Sale of the Day Banner - Only show if not actively searching
                            if searchText.isEmpty {
                                NavigationLink(destination: ShopItemDetailsView(item: saleItem)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(LinearGradient(colors: [Color.cyan.opacity(0.45), Color.blue.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                         
                                        HStack(spacing: 12) {
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
                                                 
                                                Text("Cost: \(Int(Double(saleItem.baseCost) * 0.8)) Clam Points")
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                             
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
                            }
                             
                            // Grid Items
                            if filteredItems.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No items found")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
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
                                                     
                                                    Text(user.unlockedShopItems.contains(item.id) ? "Unlocked" : "\(item.baseCost) Clam Points")
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
                        }
                         
                        Spacer(minLength: 140)
                    }
                    .padding(.top, 10)
                }
                 
                // WaterView anchored at the bottom edge if Earn Points tab is active
                if case .earnPoints = selectedTab {
                    WaterView()
                        .frame(height: 180)
                        .opacity(0.5)
                        .ignoresSafeArea(edges: .bottom)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image("clamIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        
                        // 🚀 Animated counter added to shop toolbar
                        AnimatedClamPointsText(value: user.speciesStore.totalClamPoints)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isSearchFieldFocused = false
                    }
                }
            }
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

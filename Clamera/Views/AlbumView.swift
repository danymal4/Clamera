//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI
import Kingfisher

struct FishData: Codable, Identifiable {
    let id = UUID()
    let Species: String
    let CommonName: String
    let Image: String

    enum CodingKeys: String, CodingKey {
        case Species
        case CommonName
        case Image
    }
}

import SwiftUI

struct AlbumView: View {
    
    @EnvironmentObject var user: User
    
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var showHint: Bool = false

    enum FilterOption: String, CaseIterable, Identifiable {
        case alphabetical = "Species"
        case caught = "Caught"
        case notCaught = "Uncaught"
        var id: String { rawValue }
    }

    @State private var selectedFilter: FilterOption = .caught
    
    // MARK: - Filtering
    var filteredSpecies: [Species] {
        var filtered = user.speciesStore.speciesList

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        switch selectedFilter {
        case .alphabetical:
            filtered.sort { $0.name < $1.name }
            
        case .caught:
            filtered = filtered.filter { !$0.fishList.isEmpty }
            filtered.sort { $0.name < $1.name }
            
        case .notCaught:
            filtered = filtered.filter { $0.fishList.isEmpty }
            filtered.sort { $0.name < $1.name }
        }

        return filtered
    }

    var body: some View {
        ZStack {
            
            ScrollView {
                VStack(spacing: 18) {
                    
                    // TITLE
                    Text("Album")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 20)
                    
                    // ✅ SEGMENTED CONTROL (NEW)
                    Picker("", selection: $selectedFilter) {
                        ForEach(FilterOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    // LIST
                    VStack(spacing: 14) {
                        
                        if filteredSpecies.isEmpty {
                            Text("No fish found")
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                        } else {
                            
                            ForEach(filteredSpecies) { species in
                                
                                if let index = user.speciesStore.speciesList.firstIndex(where: { $0.id == species.id }) {
                                    
                                    NavigationLink(
                                        destination: SpeciesListView(
                                            aquarium: user.aquarium,
                                            species: user.speciesStore.speciesList[index]
                                        )
                                    ) {
                                        SpeciesRow(species: user.speciesStore.speciesList[index])
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 120)
            }
            
            // SEARCH BAR (UNCHANGED)
            VStack {
                Spacer()
                
                ZStack(alignment: .trailing) {
                    
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(.leading, 10)
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(40)
                            .shadow(color: .black.opacity(0.1), radius: 8)
                            .offset(y: showSearch ? -35 : 100)
                            .animation(.easeInOut, value: showSearch)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    Button {
                        withAnimation {
                            showSearch.toggle()
                            searchText = ""
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 55, height: 55)
                                .shadow(color: .black.opacity(0.08), radius: 4)
                                .opacity(showSearch ? 0 : 1)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                                .foregroundColor(.cyan)
                        }
                        .scaleEffect(showHint ? 1.05 : 1)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                showHint.toggle()
                            }
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 70)
                }
            }
        }
        .background(Color.blue.opacity(0.02))
    }
}


// grid that's passed a species for each item
struct SpeciesRow: View {
    
    @ObservedObject var species: Species
    
    var body: some View {
        let hasFish = species.fishList.count > 0
        
        HStack(spacing: 16) {
            
       
                
            Image(UIImage(named: "\(species.name)Icon") != nil ? "\(species.name)Icon" : "Atlantic CodIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.cyan.opacity(hasFish ? 0.08 : 0.03), radius: 2, x: 0, y: 1)
            
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(species.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(hasFish ? .primary : .secondary)
                
                Text("\(species.fishList.count) Fish")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                if let heaviest = species.fishList.max(by: {
                    ($0.fishWeight ?? 0) < ($1.fishWeight ?? 0)
                }) {
                    Text("Heaviest: \(heaviest.fishWeight ?? 0) lbs")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .foregroundStyle(hasFish ? Color.cyan.opacity(0.2) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.cyan.opacity(hasFish ? 0.15 : 0.08))
                )
                .shadow(color: Color.cyan.opacity(hasFish ? 0.05 : 0.02), radius: 3, y: 1)
        )
    }
}
#Preview {
    AlbumView()
        .environmentObject(User())
}

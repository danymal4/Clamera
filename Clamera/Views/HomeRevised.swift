//
//  HomeRevised.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/25/26.
//
import SwiftUI

struct HomeRevised: View {
    
    private let ui = UIScreen.main.bounds
    @State private var floatUpDown = false
    @State private var showNameBubble = false
    @EnvironmentObject var speciesStore: SpeciesStore
    @EnvironmentObject var aquarium: AquariumFishList
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                VStack(spacing: 32) {
                    
                    HStack {
                        (
                            Text("Good Morning ")
                                .font(.title2)
                                .fontWeight(.semibold)
                            +
                            Text("James")
                                .font(.title2)
                                .fontWeight(.bold)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.75),
                                    Color.cyan.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                        Spacer()
                        
                        
                        HStack(spacing: 4) {
                            Image("clamIcon")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18).scaleEffect(1.3)
                            
                            Text("\(speciesStore.totalClamPoints)")
                                .bold()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.cyan.opacity(0.7),   // brighter top
                                        Color.blue.opacity(0.25)   // deeper bottom
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .frame(width: ui.width * 0.9, height: ui.width * 0.9)
                        
                        
                        ZStack {
                            
                            if let catchOfTheWeek = speciesStore.catchOfTheWeek {
                                // ✅ EXISTING (unchanged)
                                Image("\(catchOfTheWeek.name)Icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ui.width * 0.55, height: ui.width * 0.55)
                                    .shadow(color: .cyan.opacity(0.6), radius: 20)
                                    .shadow(color: .yellow.opacity(0.4), radius: 40)
                                    .shadow(color: .yellow.opacity(0.2), radius: 60)
                                    .offset(y: floatUpDown ? -6 : 6)
                                    .animation(
                                        .easeInOut(duration: 1.6)
                                        .repeatForever(autoreverses: true),
                                        value: floatUpDown
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                            showNameBubble = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                showNameBubble = false
                                            }
                                        }
                                    }
                                
                                if showNameBubble {
                                    Text(catchOfTheWeek.name)
                                        .font(.headline)
                                        .bold()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.85))
                                                .shadow(radius: 4)
                                        )
                                        .offset(y: -ui.width * 0.22 + (floatUpDown ? -2 : 2))
                                        .scaleEffect(showNameBubble ? 1 : 0.5)
                                        .opacity(showNameBubble ? 1 : 0)
                                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: floatUpDown)
                                        .transition(.scale.combined(with: .opacity))
                                }
                                
                            } else {
                                // ✅ NEW EMPTY STATE (fishing rod + fish placeholder)
                                ZStack {
                                    // Fishing Rod (simple vertical rectangle for now)
                                
                                    // Floating fish icon at hook
                                    Image("FishIcon")
                                        .resizable().scaleEffect(x: -1, y: 1)
                                        .scaledToFit()
                                        .frame(width: ui.width * 0.18, height: ui.width * 0.18)
                                        .offset(y: floatUpDown ? ui.width * 0.12 : ui.width * 0.08)
                                        .animation(
                                            .easeInOut(duration: 1.6)
                                            .repeatForever(autoreverses: true),
                                            value: floatUpDown
                                        )
                                    
                                    // Encouraging text
                                    Text("Congrats")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .offset(y: ui.width * 0.25)
                                }
                            }
                            
                            // ✅ Points block only visible if catchOfTheWeek exists
                            if speciesStore.catchOfTheWeek != nil {
                                VStack {
                                    Spacer()
                                    
                                    HStack {
                                        Text("Catch of the Week")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                        
                                        Spacer()
                                        
                                        Text("\(speciesStore.catchOfTheWeekPoints) Points")
                                            .bold()
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.black.opacity(0.25))
                                            .cornerRadius(10)
                                    }
                                    .padding(16)
                                    .frame(width: ui.width * 0.9)
                                }
                            }
                        }
                    }
                    
                    
                    HStack(spacing: 16) {
                        
                        statCard(
                            title: "Fish Caught",
                            value: "\(speciesStore.getFish())"
                        )
                        
                        statCard(
                            title: "This Month",
                            value: "\(speciesStore.getFish())"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    
                    
                    ZStack {
                        if let fish = speciesStore.pinnedDisplay,
                           let species = speciesStore.speciesList.first(where: { $0.name == fish.speciesName }) {
                            
                            NavigationLink(destination:
                                SpeciesListView(aquarium: aquarium, species: species)
                                    .navigationBarTitleDisplayMode(.inline)
                            ) {
                                // The card content
                                RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(.cyan)
                                    .opacity(0.25)
                                    .frame(width: ui.width * 0.9, height: ui.width * 0.35)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .overlay(
                                        HStack(spacing: 16) {
                                            Image(fishPhoto : fish.photo)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 90, height: 90)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("Pinned Catch")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                                
                                                Text(fish.speciesName)
                                                    .font(.title3)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                                
                                                if let weight = fish.fishWeight {
                                                    Text("\(weight) lbs")
                                                        .foregroundColor(.white.opacity(0.85))
                                                        .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "anchor.fill")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 20)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle()) // avoids the blue highlight
                        }else {
                            // Fallback / stock card if no pinned fish
                            Group {
                                RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(Color.cyan.opacity(0.35))
                                    .frame(width: ui.width * 0.9, height: ui.width * 0.35)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                
                                HStack(spacing: 16) {
                                    Image("opahCatch")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Pinned Catch")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.9))
                                            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                        
                                        Text("Opah")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                        
                                        Text("40 lbs")
                                            .foregroundColor(.white.opacity(0.85))
                                            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "anchor.fill")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 80)
                }
                .onAppear {
                    floatUpDown.toggle()
                }
            }
        }
        .background(
            ZStack {
                Color.blue.opacity(0.01)
                    .edgesIgnoringSafeArea(.top)
                
                
            }
        )
    }
    
    
    func statCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
    }
    
  
}




#Preview {
    HomeRevised().environmentObject(SpeciesStore()).environmentObject(AquariumFishList())
}

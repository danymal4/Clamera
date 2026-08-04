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
    @EnvironmentObject var user: User
    
    // Dynamically calculates the correct greeting based on the current hour
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning "
        case 12..<17:
            return "Good Afternoon "
        default:
            return "Good Evening "
        }
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                VStack(spacing: 32) {
                    
                    HologramHeaderView(user: user, greeting: timeBasedGreeting, floatUpDown: $floatUpDown, showNameBubble: $showNameBubble)
                    
                    // MARK: - Stats
                    HStack(spacing: 16) {
                        statCard(title: "Fish Caught", value: "\(user.speciesStore.getFish())")
                        statCard(title: "This Month", value: "\(user.speciesStore.getFish())")
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Pinned Catch
                    ZStack {
                        if let fish = user.speciesStore.pinnedDisplay,
                           let species = user.speciesStore.speciesList.first(where: { $0.name == fish.speciesName }) {
                            
                            NavigationLink(destination:
                                SpeciesListView(
                                    aquarium: user.aquarium,
                                    species: species,
                                    startWithPinnedOnly: true
                                )
                                .navigationBarTitleDisplayMode(.inline)
                            ) {
                                RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(.cyan)
                                    .opacity(0.35)
                                    .frame(width: ui.width * 0.9, height: ui.width * 0.35).scaleEffect(floatUpDown ? 1.01 : 0.99)
                                    .shadow(color: Color.cyan.opacity(floatUpDown ? 0.4 : 0.2), radius: 10, x: 0, y: 5)
                                    .animation(
                                        .easeInOut(duration: 1.2)
                                            .repeatForever(autoreverses: true),
                                        value: floatUpDown
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .overlay(
                                        HStack(spacing: 16) {
                                            Image(fishPhoto : fish.photo)
                                                .resizable()
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
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.8))
                                                .padding(10)
                                                .background(Color.black.opacity(0.2))
                                                .clipShape(Circle())
                                            
                                        }
                                        .padding(.horizontal, 20)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        } else {
                            // Fallback card with a colorful anchor icon and clean layout
                            Group {
                                RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(Color.cyan.opacity(0.35))
                                    .frame(width: ui.width * 0.9, height: ui.width * 0.35)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                
                                HStack(spacing: 16) {
                                    // Colorful Anchor icon placeholder matching the card style
                                    Image("anchor")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 45, height: 45)
                                        .foregroundColor(.white)
                                        .padding(22)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue, Color.cyan, Color.cyan, Color.cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Pinned Catch")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.9))
                                            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                        
                                        Text("No Pinned Fish")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 80)
                }
                .onAppear { floatUpDown.toggle() }
            }
        }
        .background(
            Color.blue.opacity(0.01)
                .edgesIgnoringSafeArea(.top)
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

// Fully responsive extracted subview using GeometryReader
struct HologramHeaderView: View {
    let user: User
    let greeting: String
    @Binding var floatUpDown: Bool
    @Binding var showNameBubble: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                (
                    Text(greeting)
                        .font(.title2)
                        .fontWeight(.semibold)
                    +
                    Text(user.username.lowercased())
                        .font(.title2)
                        .fontWeight(.bold)
                ).lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .truncationMode(.tail)
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
                    
                    Text("\(user.speciesStore.totalClamPoints)")
                        .bold()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            GeometryReader { geometry in
                let cardWidth = geometry.size.width * 0.9
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.75, blue: 0.85).opacity(0.75),
                                    Color(red: 0.0, green: 0.45, blue: 0.65).opacity(0.75)
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
                    
                    ZStack {
                        if let catchOfTheWeek = user.speciesStore.catchOfTheWeek {
                            Image("\(catchOfTheWeek.name)Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.6, height: cardWidth * 0.6)
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
                                    .offset(y: -cardWidth * 0.25 + (floatUpDown ? -2 : 2))
                                    .scaleEffect(showNameBubble ? 1 : 0.5)
                                    .opacity(showNameBubble ? 1 : 0)
                                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: floatUpDown)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                        } else {
                            ZStack {
                                Image("FishIcon")
                                    .resizable().scaleEffect(x: -1, y: 1)
                                    .scaledToFit()
                                    .frame(width: cardWidth * 0.2, height: cardWidth * 0.2)
                                    .offset(y: floatUpDown ? cardWidth * 0.12 : cardWidth * 0.08)
                                    .animation(
                                        .easeInOut(duration: 1.6)
                                        .repeatForever(autoreverses: true),
                                        value: floatUpDown
                                    )
                                
                                Text("Congrats")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .offset(y: cardWidth * 0.25)
                            }
                        }
                        
                        if user.speciesStore.catchOfTheWeek != nil {
                            VStack {
                                Spacer()
                                
                                HStack {
                                    Text("Catch of the Week")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                    
                                    Spacer()
                                    
                                    Text("\(user.speciesStore.catchOfTheWeekPoints) Points")
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.black.opacity(0.25))
                                        .cornerRadius(10)
                                }
                                .padding(16)
                            }
                        }
                    }
                }
                .frame(width: cardWidth, height: cardWidth)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(height: UIScreen.main.bounds.width * 0.9)
        }
    }
}

#Preview {
    HomeRevised().environmentObject(User())
}

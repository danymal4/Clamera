//
//  HomeRevised.swift
//  Clamera
//
//  Created by Ellis Kamplain on 2/25/26.
//
import SwiftUI

struct HomeRevised: View {
    
    @State private var floatUpDown = false
    @State private var showNameBubble = false
    @EnvironmentObject var user: User
    
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

    // Content width scales with the actual screen, using more space on
    // wider devices (iPad) instead of a fixed cap that only suited iPhone.
    private var contentMaxWidth: CGFloat {
        min(UIScreen.main.bounds.width * 0.92, 700)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 32) {
                    
                    HologramHeaderView(user: user, greeting: timeBasedGreeting, floatUpDown: $floatUpDown, showNameBubble: $showNameBubble)
                        .frame(maxWidth: contentMaxWidth)
                    
                    // MARK: - Stats
                    HStack(spacing: 16) {
                        statCard(title: "Fish Caught", value: "\(user.speciesStore.getFish())")
                        statCard(title: "This Month", value: "\(user.speciesStore.getFish())")
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: contentMaxWidth)
                    
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
                                HStack(spacing: 16) {
                                    FishPhotoView(photo: fish.photo, contentMode: .fill)
                                        .frame(width: 84, height: 84)
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
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.cyan.opacity(0.35))
                                        .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        } else {
                            HStack(spacing: 16) {
                                Image("anchor")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 42, height: 42)
                                    .foregroundColor(.white)
                                    .padding(18)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan, Color.cyan],
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
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.cyan.opacity(0.35))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: contentMaxWidth)
                    
                    Spacer(minLength: 80)
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                        floatUpDown.toggle()
                    }
                }
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

// Fully responsive extracted subview.
struct HologramHeaderView: View {
    @ObservedObject var user: User
    let greeting: String
    @Binding var floatUpDown: Bool
    @Binding var showNameBubble: Bool

    // Computed directly from screen width rather than a GeometryReader —
    // this is what previously caused the overlap: the card's actual size
    // was calculated one way, but the container holding it had a separate,
    // hardcoded height (380) that didn't grow to match on larger screens
    // like iPad, so the card physically overflowed into the content below
    // it. Now the container's height is always set to exactly match the
    // card's real size, on any device.
    private var cardWidth: CGFloat {
        min(UIScreen.main.bounds.width * 0.85, 600)
    }
    
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
                        .frame(width: 18, height: 18)
                        .scaleEffect(1.3)
                    
                    AnimatedClamPointsText(value: user.speciesStore.totalClamPoints)
                        .bold()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            let claimed = user.speciesStore.isCatchOfTheWeekClaimed

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
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                
                ZStack {
                    if let catchOfTheWeek = user.speciesStore.catchOfTheWeek {
                        ZStack {
                            Image("\(catchOfTheWeek.name)Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.55, height: cardWidth * 0.55)
                                .opacity(claimed ? 0.55 : 1)
                                .shadow(color: .cyan.opacity(claimed ? 0.25 : 0.6), radius: 20)
                                .shadow(color: .yellow.opacity(claimed ? 0.15 : 0.4), radius: 40)
                                .shadow(color: .yellow.opacity(claimed ? 0.08 : 0.2), radius: 60)
                                .offset(y: floatUpDown ? -3 : 3)
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

                            if claimed {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                .offset(x: cardWidth * 0.2, y: -cardWidth * 0.2)
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
                                .offset(y: -cardWidth * 0.25 + (floatUpDown ? -1 : 1))
                                .scaleEffect(showNameBubble ? 1 : 0.5)
                                .opacity(showNameBubble ? 1 : 0)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                    } else {
                        ZStack {
                            Image(systemName: "questionmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.32, height: cardWidth * 0.32)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(color: .cyan.opacity(0.6), radius: 20)
                                .shadow(color: .yellow.opacity(0.4), radius: 40)
                                .shadow(color: .yellow.opacity(0.2), radius: 60)
                                .offset(y: floatUpDown ? -3 : 3)
                            
                            Text("Coming Soon")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                .offset(y: cardWidth * 0.25)
                        }
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text("Catch of the Week")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            
                            Spacer()
                            
                            if user.speciesStore.catchOfTheWeek != nil {
                                Text(claimed ? "Claimed!" : "\(user.speciesStore.catchOfTheWeekPoints) Points")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .frame(width: cardWidth, height: cardWidth)
        }
    }
}

// MARK: - Animated Clam Points Counter
struct AnimatedClamPointsText: View {
    let value: Int
    @State private var displayValue: Double
    
    init(value: Int) {
        self.value = value
        _displayValue = State(initialValue: Double(value))
    }
    
    var body: some View {
        Text("\(Int(round(displayValue)))")
            .onChange(of: value) { _, newValue in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    displayValue = Double(newValue)
                }
            }
    }
}

#Preview {
    HomeRevised().environmentObject(User())
}

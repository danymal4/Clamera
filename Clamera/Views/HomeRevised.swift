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
    @EnvironmentObject var speciesStore: SpeciesStore
    
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
                        
                        // Points Display
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
                                        Color.cyan.opacity(0.45),
                                        Color.blue.opacity(0.20)
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
                        
                        
                        if let catchOfTheWeek = speciesStore.catchOfTheWeek {
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
                        }
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text("Catch of the Week")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
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
                    
                    
                    // MARK: Stats Section
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
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundStyle(.cyan)
                            .opacity(0.2)
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
    
    
    // MARK: Stat Card
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
    HomeRevised().environmentObject(SpeciesStore())
}

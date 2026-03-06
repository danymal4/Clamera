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
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                IconView()
                    .padding(.bottom, -30)
                
                VStack(spacing: 32) {
                    
                    // MARK: Header
                    HStack {
                        (
                            Text("Good Morning ")
                                .font(.title2)
                                .fontWeight(.semibold)
                            +
                            Text("User")
                                .font(.title2)
                                .fontWeight(.bold)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.6),
                                    Color.blue.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    
                    // MARK: Catch of the Day
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.45),
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
                        
                        Image("pufferIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: ui.width * 0.45, height: ui.width * 0.45)
                            .offset(y: floatUpDown ? -6 : 6)
                            .animation(
                                .easeInOut(duration: 1.6)
                                    .repeatForever(autoreverses: true),
                                value: floatUpDown
                            )
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text("Catch of the Day")
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("200 pts")
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
                    
                    
                    // MARK: Half Cards
                    HStack(spacing: 16) {
                        
                        // Pinned Catch
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 25)
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
                                            Color.white.opacity(0.25),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                                .frame(width: ui.width * 0.42, height: ui.width * 0.35)
                            
                            VStack {
                                Image("grouperIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ui.width * 0.18, height: ui.width * 0.18)
                                    .offset(y: floatUpDown ? -2 : 6)
                                    .animation(
                                        .easeInOut(duration: 1.3)
                                            .repeatForever(autoreverses: true),
                                        value: floatUpDown
                                    )
                                
                                Text("500 pts")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Catch of the Week (Image Card)
                        ZStack {
                            Image("clownFishExample")
                                .resizable()
                                .scaledToFill()
                                .frame(width: ui.width * 0.42, height: ui.width * 0.35)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    
                    // MARK: Streak Bar
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.55),
                                        Color.indigo.opacity(0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .frame(height: ui.width * 0.15)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Fishing Streak")
                                    .bold()
                                    .foregroundColor(.white)
                                Text("5 days in a row")
                                    .foregroundColor(.white.opacity(0.85))
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                        }
                        .padding(.horizontal, 16)
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
                Color.blue.opacity(0.01).edgesIgnoringSafeArea(.top)

                WaterView().opacity(0.3).offset(y: -400)
            }
        )
    }
}

#Preview {
    HomeRevised()
}

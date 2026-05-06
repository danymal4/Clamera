//
//  ShopView.swift
//  Clamera
//
//  Created by Isaac Clavijo (student LM) on 3/4/26.
//

import SwiftUI

struct ShopView: View {
    private let ui = UIScreen.main.bounds
    @State private var floatUpDown = false
    @EnvironmentObject var user: User
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                
                
                VStack(spacing: 32) {
                    
                    
                    HStack {
                        (
                            Text("Happy Shopping ")
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
                                Text("Login Streak: 5 Days")
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Shop Discount: 5%")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 20)
                    
                    
                    
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
                                Text("Sale of the Day")
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("Cost: 200 pts")
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
                                
                                Text("Cost: 500 pts")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Catch of the Week (Image Card)
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
                                Image("RainbowShinerIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ui.width * 0.27, height: ui.width * 0.18)
                                    .offset(y: floatUpDown ? -2 : 6)
                                    .animation(
                                        .easeInOut(duration: 1.3)
                                            .repeatForever(autoreverses: true),
                                        value: floatUpDown
                                    )
                                
                                Text("Cost: 700 pts")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(10)
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
            
            
            // Bottom Tab Bar
            Rectangle()
                .fill(Color.white)
                .overlay(Color.blue.opacity(0.06))
                .frame(height: ui.height * 0.112)
                .shadow(color: .black.opacity(0.1), radius: 10)
                .ignoresSafeArea(edges: .bottom)
                .padding(.bottom, -250)
        }
        .background(
            ZStack {
                Color.blue.opacity(0.08).edgesIgnoringSafeArea(.top)

                    WaterView().opacity(0.3)
            }
        )
    }
}

#Preview {
    ShopView()
}

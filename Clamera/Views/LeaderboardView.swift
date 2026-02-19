//
//  LeaderboardView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct LeaderboardView: View {
    
    
    let leaderboardData: [(name: String, score: String)] = [
        ("FishMaster69", "18,000"),
        ("FishNChips10", "13,000"),
        ("NotUrBaitBro", "8,000"),
        ("FindingNemo", "7,500"),
        ("RealFishHunter", "7,200"),
        ("SeaWeedKing", "6,900"),
        ("OceanMan", "6,500"),
        ("SharkBait", "6,200"),
        ("BubbleBeam", "5,800"),
        ("AquaMarine", "5,500"),
        ("DeepDiver", "5,100"),
        ("CoralReef", "4,900"),
        ("StarFishy", "4,600"),
        ("JellyJam", "4,300"),
        ("CrabbyPatty", "4,000"),
        ("LobsterMobster", "3,800"),
        ("ShrimpFried", "3,500"),
        ("WhaleHello", "3,200"),
        ("DolphinDive", "3,000"),
        ("TunaTurnup", "2,800")
    ]
    
    var body: some View {
        ZStack {
            
            WaterView()
                .ignoresSafeArea()
            IconView()
                .offset(y: -30)
            
            VStack {
                
                
                ZStack {
                    
                    VStack(spacing: -10) {
                        Text("Leaderboard ")
                            .font(.custom("IslandMoments-Regular", size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Top 20")
                            .font(.custom("IslandMoments-Regular", size: 40))
                            .foregroundColor(.blue.opacity(0.8))
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        HStack(spacing: 0) {
                            Text("Username")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                            
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                            
                            Text("ClamPoints")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                        }
                        .background(Color(red: 0.5, green: 0.9, blue: 1.0))
                        
                        // Horizontal Divider
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                        
                        // 4. Data Rows
                        ForEach(0..<leaderboardData.count, id: \.self) { index in
                            let entry = leaderboardData[index]
                            
                            HStack(spacing: 0) {
                                Text(entry.name)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                
                                // Vertical Divider inside row
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 1)
                                
                                Text(entry.score)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .background(Color(red: 0.6, green: 0.85, blue: 1.0)) // Light Blue Row
                            
                            // Divider between rows (except after the last one)
                            if index < leaderboardData.count - 1 {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(height: 1)
                            }
                        }
                    }
                    // 5. Clip Shape and Border for the entire table
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .padding(.horizontal, 10)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

#Preview {
    LeaderboardView()
}

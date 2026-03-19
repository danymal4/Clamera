//
//  LeaderboardView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        ZStack {
          
            
            VStack {
                
                
                ZStack {
                    
                    VStack(spacing: -10) {
                        Text("Leaderboard ")
                            .font(.custom("AkayaTelivigala-regular", size: 70))
                            .foregroundColor(.blue)
                        
                        Text("Top 20")
                            .font(.custom("AkayaTelivigala-regular", size: 40))
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
                        
                    
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                        
                        // data rows
                        DataView()
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
                ZStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(height: 83)
                }
                .edgesIgnoringSafeArea(.bottom).padding(.bottom, -100)
            }
        }
    }
}

struct DataView: View {
    
    @EnvironmentObject var user: User
    @State var leaderboardData: [LeaderboardUser] = [
        LeaderboardUser(name: "FishMaster69", points: 18000),
        LeaderboardUser(name: "FishNChips10", points: 13000),
        LeaderboardUser(name: "NotUrBaitBro", points: 8000),
        LeaderboardUser(name: "FindingNemo", points: 7500),
        LeaderboardUser(name: "RealFishHunter", points: 7200),
        LeaderboardUser(name: "SeaWeedKing", points: 6900),
        LeaderboardUser(name: "OceanMan", points: 6500),
        LeaderboardUser(name: "SharkBait", points: 6200),
        LeaderboardUser(name: "BubbleBeam", points: 5800),
        LeaderboardUser(name: "AquaMarine", points: 5500),
        LeaderboardUser(name: "DeepDiver", points: 5100),
        LeaderboardUser(name: "CoralReef", points: 4900),
        LeaderboardUser(name: "StarFishy", points: 4600),
        LeaderboardUser(name: "JellyJam", points: 4300),
        LeaderboardUser(name: "CrabbyPatty", points: 4000),
        LeaderboardUser(name: "LobsterMobster", points: 3800),
        LeaderboardUser(name: "ShrimpFried", points: 3500),
        LeaderboardUser(name: "WhaleHello", points: 3200),
        LeaderboardUser(name: "DolphinDive", points: 3000)
    ]
    
    func fixUsers() {
        leaderboardData.append(user.leaderboardUser)
        leaderboardData = leaderboardData.sorted()
    }
    
    var body: some View {
        
        ForEach($leaderboardData) { $leaderboardUser in
            
            HStack(spacing: 0) {
                Text(leaderboardUser.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                
                // Vertical Divider inside row
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1)
                
                Text(String(leaderboardUser.points))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .background(Color(red: 0.6, green: 0.85, blue: 1.0)) // Light Blue Row
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
        }
        .onAppear {
            fixUsers()
        }
    }
}


#Preview {
    LeaderboardView()
        .environmentObject(User())
}

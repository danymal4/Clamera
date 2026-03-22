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
        VStack(spacing: 0) {

            // MARK: - Title
            VStack(spacing: 4) {
                Text("Leaderboard")
                    .font(.system(size: 34, weight: .bold))

                Text("Top 20")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            // MARK: - List
            ScrollView {
                VStack(spacing: 12) {
                    DataView()
                }
                .padding(.top, 16) // <-- added extra top padding for breathing room
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .background(Color.blue.opacity(0.01))
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
        ForEach(Array(leaderboardData.enumerated()), id: \.element.id) { index, leaderboardUser in
            let rank = index + 1
            let isTopThree = rank <= 3
            let isCurrentUser = leaderboardUser.name == user.username
            
            HStack(spacing: 12) {
                // MARK: - Rank
                Text("#\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isTopThree ? Color(red: 1.0, green: 0.8, blue: 0.3) : .secondary)
                    .frame(width: 40)
                
                // MARK: - Username
                Text(leaderboardUser.name)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // MARK: - Points
                HStack(spacing: 4) {
                    Image("clamIcon")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text("\(leaderboardUser.points)")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        isTopThree
                        ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.08)
                        : Color.white
                    )
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isCurrentUser
                        ? Color.cyan.opacity(0.4)
                        : (isTopThree
                           ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.3)
                           : Color.black.opacity(0.05)),
                        lineWidth: isCurrentUser ? 2 : 1
                    )
            )
            .scaleEffect(isCurrentUser ? 1.02 : 1.0)
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

//
//  LeaderboardView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI


struct LeaderboardView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var leaderboard: LeaderboardData
    
    var body: some View {
        VStack(spacing: 0) {
            
            
            VStack(spacing: 4) {
                Text("Leaderboard")
                    .font(.system(size: 34, weight: .bold))
                
                Text("Top 20")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            
    
            ScrollView {
                VStack(spacing: 12) {
                    DataView()
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .background(Color.blue.opacity(0.01))
        
    }
}

// MARK: - Data View
struct DataView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var leaderboard: LeaderboardData
    
    var body: some View {
        ForEach(Array(leaderboard.users.prefix(20).enumerated()), id: \.element.id) { index, leaderboardUser in
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
    }
}

// MARK: - Preview
#Preview {
    LeaderboardView()
        .environmentObject(User())
        .environmentObject(LeaderboardData())
}

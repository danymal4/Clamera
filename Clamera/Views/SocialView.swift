//
//  SocialView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/17/26.
//

import SwiftUI

struct SocialView: View {
    var body: some View {
        ZStack {
            IconView()
            
            VStack(spacing: 35) {
                
                // Section Title
                Text("Social")
                    .font(.system(size: 42, weight: .bold)) // matches other titles
                    .foregroundColor(.black)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
                    .padding(.top, 60)
                
                VStack(spacing: 25) {
                    
                    // Friends Button
                    Button {
                        // action
                    } label: {
                        socialRow(imageName: "friends", title: "Friends")
                    }
                    
                    // Leaderboard Navigation
                    NavigationLink(destination: LeaderboardView()) {
                        socialRow(imageName: "Trophy", title: "Leaderboard")
                    }
                    
                    // Shop Button
                    Button {
                        // action
                    } label: {
                        socialRow(imageName: "Shop", title: "Shop")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(Color.blue.opacity(0.01))
    }
    
    // MARK: - Social Row
    private func socialRow(imageName: String, title: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.cyan.opacity(0.15)) // light cyan
                .frame(height: UIScreen.main.bounds.width * 0.35)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: min(UIScreen.main.bounds.width * 0.15, 120),
                        height: min(UIScreen.main.bounds.width * 0.15, 120)
                    )
                
                Text(title)
                    .font(.system(size: 22, weight: .semibold)) // semi-bold
                    .foregroundColor(.black.opacity(0.85)) // slightly softer
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SocialView()
}

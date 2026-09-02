//
//  SocialView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/17/26.
//

import SwiftUI

struct SocialView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var leaderboard: LeaderboardData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                 
                Text("Social")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.black)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
                    .padding(.top, 60)
                 
                VStack(spacing: 25) {
                     
                    NavigationLink(destination: ProfileView()) {
                        socialRow(
                            imageName: user.profilePicture,
                            title: user.username,
                            subtitle: "View your profile",
                            isHighlighted: true
                        )
                    }
                     
                    NavigationLink(destination: FriendsListView(user: user)) {
                        socialRow(
                            imageName: "friends",
                            title: "Friends",
                            subtitle: "10 friends",
                            isHighlighted: false
                        )
                    }
                     
                    NavigationLink(destination: FishOfFameView()) {
                        socialRow(
                            imageName: "Trophy",
                            title: "Fish of Fame",
                            subtitle: "Manage your trophy catalog & posts",
                            isHighlighted: false
                        )
                    }
                     
                    NavigationLink(destination: ShopView()) {
                        socialRow(
                            imageName: "Shop",
                            title: "Shop",
                            subtitle: "New items available",
                            isHighlighted: false
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal)
        }
    }
        .background(Color.blue.opacity(0.01))
    }
    
    private func socialRow(imageName: String, title: String, subtitle: String? = nil, isHighlighted: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(isHighlighted ? Color.cyan.opacity(0.25) : Color.cyan.opacity(0.15))
                .frame(height: UIScreen.main.bounds.width * 0.35)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
             
            HStack(spacing: 20) {
                if isHighlighted {
                    if imageName.hasPrefix("http") {
                        AsyncImage(url: URL(string: imageName)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: min(UIScreen.main.bounds.width * 0.15, 120),
                              height: min(UIScreen.main.bounds.width * 0.15, 120))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    } else if let data = Data(base64Encoded: imageName),
                              let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: min(UIScreen.main.bounds.width * 0.15, 120),
                                  height: min(UIScreen.main.bounds.width * 0.15, 120))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(UIScreen.main.bounds.width * 0.15, 120),
                                  height: min(UIScreen.main.bounds.width * 0.15, 120))
                            .foregroundColor(.gray.opacity(0.6))
                            .background(Circle().fill(Color(.systemGray5)))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                } else {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(UIScreen.main.bounds.width * 0.15, 120),
                              height: min(UIScreen.main.bounds.width * 0.15, 120))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                     
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black.opacity(0.85))
                     
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                 
                Spacer()
                 
                Image(systemName: "chevron.right")
                    .foregroundColor(.black.opacity(0.4))
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SocialView()
        .environmentObject(User())
        .environmentObject(LeaderboardData())
}

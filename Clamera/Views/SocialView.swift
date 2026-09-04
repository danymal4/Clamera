//
//  SocialView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/17/26.
//

import SwiftUI

struct SocialView: View {
    @EnvironmentObject var user: User
    
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
                            subtitle: "\(user.friends.count) \(user.friends.count == 1 ? "friend" : "friends")",
                            isHighlighted: false
                        )
                    }
                    
                    NavigationLink(destination: FishOfFameView()) {
                        socialRow(
                            imageName: "FishTrophyIcon",
                            title: "Fish of Fame",
                            subtitle: "Your most prized catches",
                            isHighlighted: false
                        )
                    }
                    
                    NavigationLink(destination: ShopView()) {
                        socialRow(
                            imageName: "Shop",
                            title: "Shop",
                            subtitle: "Decorate your Aquarium with fish icons",
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
        let isTrophy = (imageName == "FishTrophyIcon")
        let slotSize: CGFloat = 70
        
        return ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(isHighlighted ? Color.cyan.opacity(0.25) : Color.cyan.opacity(0.15))
                .frame(height: 110)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            HStack(spacing: 20) {
                // Fixed-width icon slot keeps text aligned on every row
                ZStack {
                    if isHighlighted {
                        if imageName.hasPrefix("http") {
                            AsyncImage(url: URL(string: imageName)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: slotSize, height: slotSize)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        } else if let data = Data(base64Encoded: imageName),
                                  let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: slotSize, height: slotSize)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: slotSize, height: slotSize)
                                .foregroundColor(.gray.opacity(0.6))
                                .background(Circle().fill(Color(.systemGray5)))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                    } else {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: slotSize, height: slotSize)
                            .scaleEffect(isTrophy ? 1.7 : 1.0)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                }
                .frame(width: slotSize, height: slotSize)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black.opacity(0.85))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black.opacity(0.4))
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    SocialView()
        .environmentObject(User())
}

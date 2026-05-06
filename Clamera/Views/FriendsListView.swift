//
//  FriendsListView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student Lower Merion High School) on 4/9/26.
//

import SwiftUI

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let imageName: String
    let isOnline: Bool
}

struct FriendsListView: View {
    
    @EnvironmentObject var user: User
    @State private var searchText = ""
    // Mock data
    let friends: [Friend] = [
        Friend(name: "Jake Thompson", username: "@jaket", imageName: "fisherman", isOnline: true),
        Friend(name: "Sarah Lee", username: "@sarahlee", imageName: "fisherman", isOnline: false),
        Friend(name: "Chris Evans", username: "@cevans", imageName: "fisherman", isOnline: true),
        Friend(name: "Maya Patel", username: "@mayap", imageName: "fisherman", isOnline: false)
    ]
    
    var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    
                    ForEach(friends) { friend in
                        friendRow(friend)
                    }
                }
                .padding()
            }
            .navigationTitle("Friends")
            .searchable(text: $searchText, prompt: "Search friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.cyan)
            }
        }
            }
            .background(Color(.systemGray6))
        }

    // MARK: - Friend Row
    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 15) {
            
            // Profile Image
            ZStack(alignment: .bottomTrailing) {
                Image(friend.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                
                // Online indicator
                Circle()
                    .fill(friend.isOnline ? Color.green : Color.gray)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            // Name + Username
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
                
                Text(friend.username)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Action button (example)
            Button {
                // action
            } label: {
                Text("View")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.cyan.opacity(0.12))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
    }
}

#Preview {
    FriendsListView().environmentObject(User())
}


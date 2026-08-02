//
//  FriendsListView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student Lower Merion High School) on 4/9/26.
//

import SwiftUI

struct Friend: Identifiable, Equatable {
    let id: String // Modified to match Firestore User ID
    let name: String
    let username: String
    let imageName: String
    let isOnline: Bool
}

struct FriendsListView: View {
    @EnvironmentObject var user: User
    
    @State private var searchText = ""
    @State private var friends: [Friend] = []
    
    // Alert state for adding new friends
    @State private var showAddFriendAlert = false
    @State private var friendUsernameInput = ""
    @State private var statusAlertMessage = ""
    @State private var showStatusAlert = false
    @State private var isLoading = false
    
    // Filter friends list based on the search bar input
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.username.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Friends...")
                } else if friends.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No friends added yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap the + button to search and add real accounts!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredFriends) { friend in
                                friendRow(friend)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Friends")
            .searchable(text: $searchText, prompt: "Search friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        friendUsernameInput = ""
                        showAddFriendAlert = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.cyan)
                    }
                }
            }
            .background(Color(.systemGray6))
            .onAppear {
                loadFriendsList()
            }
            // Alert 1: Prompt to enter friend's username
            .alert("Add Friend", isPresented: $showAddFriendAlert) {
                TextField("Exact Username", text: $friendUsernameInput)
                    .autocapitalization(.none)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addNewFriend(username: friendUsernameInput.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } message: {
                Text("Enter the exact username of the account you want to add.")
            }
            // Alert 2: Success / Failure feedback
            .alert("Friend Status", isPresented: $showStatusAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(statusAlertMessage)
            }
        }
    }
    
    // MARK: - Core Logic Helpers
    
    private func loadFriendsList() {
        guard !user.friends.isEmpty else {
            self.friends = []
            return
        }
        
        Task {
            let list = await FirestoreManager.shared.fetchUsers(byIds: user.friends)
            await MainActor.run {
                self.friends = list
            }
        }
    }
    
    private func addNewFriend(username: String) {
        guard !username.isEmpty else { return }
        
        if username.lowercased() == user.username.lowercased() {
            statusAlertMessage = "You cannot add yourself as a friend!"
            showStatusAlert = true
            return
        }
        
        isLoading = true
        Task {
            // Find the user in Firestore
            if let foundUser = await FirestoreManager.shared.findUserByUsername(username) {
                
                // Check if they are already on your list
                if user.friends.contains(foundUser.id) {
                    await MainActor.run {
                        statusAlertMessage = "\(username) is already in your friends list."
                        showStatusAlert = true
                        isLoading = false
                    }
                    return
                }
                
                // Add to local app memory state
                await MainActor.run {
                    user.friends.append(foundUser.id)
                }
                
                // Save updated user data to cloud
                await FirestoreManager.shared.saveUser(user: user)
                
                // Reload UI
                loadFriendsList()
                
                await MainActor.run {
                    statusAlertMessage = "Successfully added \(username)!"
                    showStatusAlert = true
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    statusAlertMessage = "No user found with the username: \"\(username)\""
                    showStatusAlert = true
                    isLoading = false
                }
            }
        }
    }

    // MARK: - Friend Row View Builder
    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 15) {
            
            // Profile Image
            ZStack(alignment: .bottomTrailing) {
                if friend.imageName.hasPrefix("http") {
                    AsyncImage(url: URL(string: friend.imageName)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                } else {
                    Image(friend.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                }
                
                // Online indicator
                Circle()
                    .fill(friend.isOnline ? Color.green : Color.gray)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            // Name + Username info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
                
                Text(friend.username)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Action button
            Button {
                // View profile or look at their species index
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


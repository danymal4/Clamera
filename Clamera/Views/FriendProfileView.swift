//
//  FriendProfileView.swift
//  Clamera
//
//  Created by Isaac Clavijo on 8/31/26.
//

import SwiftUI

struct FriendProfileView: View {
    let friendId: String
    
    @EnvironmentObject var user: User
    @Environment(\.dismiss) var dismiss
    
    @State private var friendUser: User?
    @State private var isLoading = true
    @State private var showRemoveConfirmation = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading profile...")
            } else if let friendUser {
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // MARK: - Profile Picture & Username
                        VStack(spacing: 10) {
                            if friendUser.profilePicture.hasPrefix("http") {
                                AsyncImage(url: URL(string: friendUser.profilePicture)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                            } else if let data = Data(base64Encoded: friendUser.profilePicture),
                                      let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Circle().fill(Color(.systemGray5)))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                            }

                            Text(friendUser.username)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black.opacity(0.85))
                        }
                        .padding(.top, 40)

                        // MARK: - Filtered Stats Card (Fish Caught, Species Caught, Clam Points)
                        VStack(spacing: 0) {
                            infoRow(title: "Fish Caught", value: "\(friendUser.speciesStore.getFish())")
                            divider()
                            infoRow(title: "Species Caught", value: "\(friendUser.speciesStore.getSpecies())/\(friendUser.speciesStore.speciesList.count)")
                            divider()
                            infoRow(title: "Clam Points", value: "\(friendUser.speciesStore.totalClamPoints)")
                        }
                        .background(RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4))
                        .padding(.horizontal)

                        // MARK: - Aquarium & Fish of Fame Navigation Links
                        VStack(spacing: 16) {
                            // Friend's Aquarium Row
                            HStack {
                                Text("\(friendUser.username)'s Aquarium")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.85))
                                Spacer()
                                NavigationLink(destination: friendAquariumDestination(friendUser: friendUser)) {
                                    Text("View")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.cyan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.cyan.opacity(0.12))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                            .padding(.horizontal)

                            // Friend's Fish of Fame Row
                            HStack {
                                Text("\(friendUser.username)'s Fish of Fame")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.85))
                                Spacer()
                                NavigationLink(destination: friendFishOfFameDestination(friendUser: friendUser)) {
                                    Text("View")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.cyan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.cyan.opacity(0.12))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                            .padding(.horizontal)
                        }

                        // MARK: - Remove Friend Button
                        Button(role: .destructive) {
                            showRemoveConfirmation = true
                        } label: {
                            Text("Remove Friend")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.red.opacity(0.7), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 30)
                    }
                }
            } else {
                Text("Failed to load friend's profile.")
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.blue.opacity(0.01))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Are you sure you want to remove this friend?", isPresented: $showRemoveConfirmation, titleVisibility: .visible) {
            Button("Remove Friend", role: .destructive) {
                Task {
                    await FirestoreManager.shared.removeFriend(friendId: friendId, currentUserId: user.id)
                    await MainActor.run {
                        user.friends.removeAll { $0 == friendId }
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            Task {
                let profile = await FirestoreManager.shared.fetchFriendProfile(userId: friendId)
                await MainActor.run {
                    self.friendUser = profile
                    self.isLoading = false
                }
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.black)
                .bold()
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }

    private func divider() -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.05))
            .frame(height: 1)
            .padding(.horizontal)
    }
    
    @ViewBuilder
    private func friendAquariumDestination(friendUser: User) -> some View {
        ScrollView {
            AquariumView(showBottomBar: .constant(false), allowEditing: false)
                .environmentObject(friendUser)
                .frame(height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding()
        }
        .navigationTitle("\(friendUser.username)'s Aquarium")
    }
    
    @ViewBuilder
    private func friendFishOfFameDestination(friendUser: User) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                if !friendUser.fishOfFamePosts.isEmpty {
                    ForEach(Array(friendUser.fishOfFamePosts.enumerated()), id: \.offset) { index, post in
                        VStack(alignment: .leading, spacing: 12) {
                            if post.photo.hasPrefix("http") {
                                AsyncImage(url: URL(string: post.photo)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 250)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .background(Color.cyan.opacity(0.1))
                                .cornerRadius(16)
                            } else {
                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                                let fileURL = documentsDirectory?.appendingPathComponent(post.photo)
                                let loadedImage = fileURL.flatMap { UIImage(contentsOfFile: $0.path) } ?? UIImage(named: post.photo) ?? UIImage(systemName: "photo")!

                                Image(uiImage: loadedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 250)
                                    .background(Color.cyan.opacity(0.1))
                                    .cornerRadius(16)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.speciesName.capitalized)
                                    .font(.title3.bold())
                                
                                if !post.caption.isEmpty {
                                    Text(post.caption)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        .padding(.horizontal)
                    }
                } else {
                    Text("No Fish of Fame posts yet.")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("\(friendUser.username)'s Fish of Fame")
        .background(Color(.systemGray6))
    }
}

#Preview {
    NavigationView {
        FriendProfileView(friendId: "sample_id")
    }
}

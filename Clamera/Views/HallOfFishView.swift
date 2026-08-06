//
//  HallOfFishView.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/5/26.
//

import SwiftUI

struct FishPost: Identifiable, Codable {
    let id: UUID
    let photo: String
    let speciesName: String
    let caption: String
    let datePosted: Date
}

struct HallOfFishView: View {
    @EnvironmentObject var user: User
    @State private var showAlbumPicker = false
    @State private var hallOfFishPosts: [FishPost] = []
    @State private var postToDelete: FishPost? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Header & Add Button
                HStack {
                    Text("Hall of Fish")
                        .font(.system(size: 32, weight: .bold))
                    Spacer()
                    
                    Button {
                        showAlbumPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                            Text("Add Catch")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.cyan)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: Color.cyan.opacity(0.3), radius: 4, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                if hallOfFishPosts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.6))
                        Text("No trophy catches yet!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap 'Add Catch' to showcase your favorite fish for friends to see.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 80)
                } else {
                    // Instagram-style Feed
                    LazyVStack(spacing: 24) {
                        ForEach(hallOfFishPosts) { post in
                            VStack(alignment: .leading, spacing: 10) {
                                
                                // Profile / Username Header matching Account Profile Picture
                                HStack(spacing: 10) {
                                    if user.profilePicture.hasPrefix("http"), let url = URL(string: user.profilePicture) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(Color.cyan.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text(user.username.prefix(1).uppercased())
                                                    .bold()
                                                    .foregroundColor(.cyan)
                                            )
                                    }
                                    
                                    Text(user.username)
                                        .font(.system(size: 15, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Text(post.datePosted.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    // Remove/Delete Post Button
                                    Button {
                                        postToDelete = post
                                        showDeleteConfirm = true
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    .padding(.leading, 6)
                                }
                                .padding(.horizontal, 16)

                                // Post Image
                                Image(fishPhoto: post.photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)

                                // Caption & Species
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.speciesName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(post.caption)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black.opacity(0.8))
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.blue.opacity(0.01))
        .sheet(isPresented: $showAlbumPicker) {
            PostPreviewPickerView { selectedFish, speciesName in
                let newPost = FishPost(
                    id: UUID(),
                    photo: selectedFish.photo,
                    speciesName: speciesName,
                    caption: selectedFish.description,
                    datePosted: Date()
                )
                hallOfFishPosts.insert(newPost, at: 0)
            }
            .environmentObject(user)
        }
        .confirmationDialog("Remove this post from your Hall of Fish?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let post = postToDelete {
                    hallOfFishPosts.removeAll { $0.id == post.id }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - Album Picker & Preview Sheet
struct PostPreviewPickerView: View {
    @EnvironmentObject var user: User
    @Environment(\.dismiss) var dismiss
    
    var onPublish: (Fish, String) -> Void
    @State private var selectedFishToPreview: Fish? = nil
    @State private var parentSpeciesName: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                if let fish = selectedFishToPreview {
                    // PREVIEW STEP
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Post Preview")
                                .font(.title2)
                                .bold()
                                .padding(.top, 20)

                            VStack(alignment: .leading, spacing: 12) {
                                Image(fishPhoto: fish.photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width - 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                Text(parentSpeciesName)
                                    .font(.headline)
                                
                                Text(fish.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.06), radius: 8)
                            .padding(.horizontal)

                            Button {
                                onPublish(fish, parentSpeciesName)
                                dismiss()
                            } label: {
                                Text("Share to Hall of Fish")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.cyan)
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 10)
                        }
                    }
                } else {
                    // SELECTION STEP (Album of Caught Fish)
                    List {
                        ForEach(user.speciesStore.speciesList) { species in
                            if !species.fishList.isEmpty {
                                Section(header: Text(species.name)) {
                                    ForEach(species.fishList) { fish in
                                        Button {
                                            selectedFishToPreview = fish
                                            parentSpeciesName = species.name
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(fishPhoto: fish.photo)
                                                    .resizable()
                                                    .frame(width: 45, height: 45)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                                VStack(alignment: .leading) {
                                                    Text(fish.description)
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                        .lineLimit(1)
                                                    Text("Caught: \(fish.dateCaught.formatted(date: .abbreviated, time: .omitted))")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Select a Catch")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dismiss() }
                        }
                    }
                }
            }
            .background(Color.blue.opacity(0.02))
        }
    }
}

#Preview {
    HallOfFishView()
        .environmentObject(User())
}

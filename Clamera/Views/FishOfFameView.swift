//
//  FishOfFameView.swift
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

struct FishOfFameView: View {
    @EnvironmentObject var user: User
    @State private var showAlbumPicker = false
    @State private var pendingPost: FishPost? = nil

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                     
                    // Header & Add Button
                    HStack {
                        Text("Fish of Fame")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue, Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
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

                    if user.fishOfFamePosts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color.secondary.opacity(0.6))
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
                        VStack(spacing: 24) {
                            ForEach(user.fishOfFamePosts) { post in
                                FishPostRowView(post: post)
                                    .id(post.id)
                            }
                        }
                        .id(user.fishOfFamePosts.count)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color.blue.opacity(0.01))
            .sheet(isPresented: $showAlbumPicker, onDismiss: {
                if let post = pendingPost {
                    if !user.fishOfFamePosts.contains(where: { $0.id == post.id }) {
                        user.fishOfFamePosts.insert(post, at: 0)
                        Task {
                            if let authUser = AuthManager.shared.user {
                                await FirestoreManager.shared.saveUser(user: authUser)
                            }
                        }
                    }
                    pendingPost = nil
                }
            }) {
                PostPreviewPickerView { selectedFish, speciesName in
                    pendingPost = FishPost(
                        id: selectedFish.id,
                        photo: selectedFish.photo,
                        speciesName: speciesName,
                        caption: selectedFish.description,
                        datePosted: selectedFish.dateCaught
                    )
                }
                .environmentObject(user)
            }
        }
    }
}

// Extracted Row into a dedicated View struct.
struct FishPostRowView: View {
    @EnvironmentObject var user: User
    let post: FishPost
    
    private var goldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.86, green: 0.65, blue: 0.18),
                Color(red: 0.98, green: 0.82, blue: 0.38),
                Color(red: 0.84, green: 0.58, blue: 0.12)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
             
            // Profile / Username Header
            HStack(spacing: 10) {
                if user.profilePicture.hasPrefix("http"), let url = URL(string: user.profilePicture) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else if let data = Data(base64Encoded: user.profilePicture),
                          let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
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
            }
            .padding(.horizontal, 16)

            // Photo + Caption area — tapping navigates to FishDetailsView,
            // where "Remove from Fish of Fame" now lives as the reliable
            // way to unpost a catch.
            NavigationLink(destination: FishDetailsView(speciesStore: user.speciesStore, aquarium: user.aquarium, fishID: post.id)) {
                VStack(alignment: .leading, spacing: 8) {
                    FishPhotoView(photo: post.photo, contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                        .background(Color.cyan.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.speciesName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(goldGradient)
                            .shadow(color: Color(red: 0.7, green: 0.5, blue: 0.1).opacity(0.25), radius: 1, x: 0.5, y: 0.5)
                         
                        if !post.caption.isEmpty {
                            Text(post.caption)
                                .font(.system(size: 14))
                                .foregroundColor(Color.black.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
        .padding(.horizontal, 16)
    }
}

// MARK: - Album Picker & Preview Sheet
struct PostPreviewPickerView: View {
    @EnvironmentObject var user: User
    @Environment(\.dismiss) var dismiss
     
    var onPublish: (Fish, String) -> Void
    @State private var selectedFishToPreview: Fish? = nil
    @State private var parentSpeciesName: String = ""

    private var goldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.86, green: 0.65, blue: 0.18),
                Color(red: 0.98, green: 0.82, blue: 0.38),
                Color(red: 0.84, green: 0.58, blue: 0.12)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let fish = selectedFishToPreview {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Post Preview")
                                .font(.title2)
                                .bold()
                                .padding(.top, 20)

                            VStack(alignment: .leading, spacing: 12) {
                                FishPhotoView(photo: fish.photo, contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width - 64)
                                    .background(Color.cyan.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                Text(parentSpeciesName)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(goldGradient)
                                    .shadow(color: Color(red: 0.7, green: 0.5, blue: 0.1).opacity(0.25), radius: 1, x: 0.5, y: 0.5)
                                 
                                if !fish.description.isEmpty {
                                    Text(fish.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.06), radius: 8)
                            .padding(.horizontal)

                            Button {
                                onPublish(fish, parentSpeciesName)
                                dismiss()
                            } label: {
                                Text("Share to Fish of Fame")
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
                                                FishPhotoView(photo: fish.photo, contentMode: .fill)
                                                    .frame(width: 45, height: 45)
                                                    .background(Color.cyan.opacity(0.08))
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                                VStack(alignment: .leading) {
                                                    Text(fish.description.isEmpty ? species.name : fish.description)
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
    FishOfFameView()
        .environmentObject(User())
}

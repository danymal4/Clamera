//
//  FriendsListView.swift
//  Clamera
//
//  Created by Isaac Clavijo on 3/25/26.
//
 
import SwiftUI
import FirebaseFirestore
 
struct FriendsListView: View {
    @ObservedObject var user: User
    @State private var selectedTab: FriendTab = .friends
 
    @State private var friendObjects: [Friend] = []
    @State private var incomingProfiles: [(id: String, name: String, profilePic: String)] = []
    @State private var outgoingProfiles: [(id: String, name: String, profilePic: String)] = []
 
    @State private var showAddFriend = false
    @State private var listenerRegistration: ListenerRegistration? = nil
 
    enum FriendTab {
        case friends, pending
    }
 
    var body: some View {
        VStack(spacing: 0) {
            // Header Tabs
            HStack(spacing: 0) {
                TabButton(title: "Friends", isSelected: selectedTab == .friends) {
                    selectedTab = .friends
                }
                TabButton(title: "Pending Requests", isSelected: selectedTab == .pending) {
                    selectedTab = .pending
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
 
            if selectedTab == .friends {
                friendsContent
            } else {
                pendingContent
            }
 
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddFriend = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showAddFriend) {
            AddFriendSheet(user: user, isPresented: $showAddFriend)
        }
        .onAppear {
            loadFriendData()
            startListeningToUserChanges()
        }
        .onDisappear {
            listenerRegistration?.remove()
        }
        .onChange(of: user.friends) { loadFriendData() }
        .onChange(of: user.incomingRequests) { loadFriendData() }
        .onChange(of: user.outgoingRequests) { loadFriendData() }
        .onChange(of: user.blockedUsers) { loadFriendData() }
    }
 
    private func startListeningToUserChanges() {
        guard !user.id.isEmpty else { return }
        listenerRegistration?.remove()
 
        let db = Firestore.firestore()
        listenerRegistration = db.collection("users").document(user.id).addSnapshotListener { snapshot, error in
            guard let document = snapshot, document.exists, let data = document.data() else { return }
 
            Task { @MainActor in
                self.user.friends = data["friends"] as? [String] ?? self.user.friends
                self.user.incomingRequests = data["incoming_requests"] as? [String] ?? self.user.incomingRequests
                self.user.outgoingRequests = data["outgoing_requests"] as? [String] ?? self.user.outgoingRequests
                self.user.blockedUsers = data["blocked_users"] as? [String] ?? self.user.blockedUsers
                loadFriendData()
            }
        }
    }
 
    private var friendsContent: some View {
        List {
            if friendObjects.isEmpty {
                VStack(spacing: 16) {
                    Text("No friends added yet!")
                        .font(.headline)
                        .foregroundColor(.secondary)
 
                    Button {
                        showAddFriend = true
                    } label: {
                        Text("Add Friend")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 24)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            } else {
                ForEach(friendObjects) { friend in
                    NavigationLink(destination: FriendProfileView(friendId: friend.id)) {
                        HStack(spacing: 12) {
                            if friend.imageName.hasPrefix("http") {
                                AsyncImage(url: URL(string: friend.imageName)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                            } else if let data = Data(base64Encoded: friend.imageName),
                                      let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Circle().fill(Color(.systemGray5)))
                                    .clipShape(Circle())
                            }
 
                            VStack(alignment: .leading, spacing: 4) {
                                Text(friend.name)
                                    .font(.headline)
                                Text(friend.username)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
 
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    // The index here is a position in `friendObjects` (what's
                    // actually on screen), not in `user.friends` — those two
                    // arrays can be in a different order or length (friendObjects
                    // is built from an async fetch and has blocked users
                    // filtered out). Reading user.friends[index] used the wrong
                    // array entirely. Resolve the real friend ID first.
                    let idsToRemove = indexSet.compactMap { friendObjects.indices.contains($0) ? friendObjects[$0].id : nil }
                    for friendId in idsToRemove {
                        Task {
                            await FirestoreManager.shared.removeFriend(friendId: friendId, currentUserId: user.id)
                            await MainActor.run {
                                // Remove by value, not by index: the Firestore
                                // snapshot listener in startListeningToUserChanges()
                                // can already have updated user.friends by the time
                                // this await returns, which is what made the old
                                // index-based removal crash with "Index out of range".
                                user.friends.removeAll { $0 == friendId }
                                loadFriendData()
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
 
    private var pendingContent: some View {
        List {
            if !incomingProfiles.isEmpty {
                Section(header: Text("Incoming Requests")) {
                    ForEach(incomingProfiles, id: \.id) { req in
                        HStack(spacing: 12) {
                            if req.profilePic.hasPrefix("http") {
                                AsyncImage(url: URL(string: req.profilePic)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else if let data = Data(base64Encoded: req.profilePic),
                                      let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Circle().fill(Color(.systemGray5)))
                                    .clipShape(Circle())
                            }
 
                            Text(req.name)
                                .font(.headline)
 
                            Spacer()
 
                            Button("Accept") {
                                Task {
                                    await FirestoreManager.shared.acceptFriendRequest(senderId: req.id, currentUserId: user.id)
                                    user.incomingRequests.removeAll { $0 == req.id }
                                    user.friends.append(req.id)
                                    loadFriendData()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .controlSize(.small)
 
                            Button("Decline") {
                                Task {
                                    await FirestoreManager.shared.declineFriendRequest(senderId: req.id, currentUserId: user.id)
                                    user.incomingRequests.removeAll { $0 == req.id }
                                    loadFriendData()
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .controlSize(.small)
                        }
                    }
                }
            }
 
            if !outgoingProfiles.isEmpty {
                Section(header: Text("Sent Requests")) {
                    ForEach(outgoingProfiles, id: \.id) { req in
                        HStack(spacing: 12) {
                            if req.profilePic.hasPrefix("http") {
                                AsyncImage(url: URL(string: req.profilePic)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else if let data = Data(base64Encoded: req.profilePic),
                                      let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Circle().fill(Color(.systemGray5)))
                                    .clipShape(Circle())
                            }
 
                            Text(req.name)
                                .font(.headline)
 
                            Spacer()
 
                            Button("Cancel") {
                                Task {
                                    await FirestoreManager.shared.cancelFriendRequest(targetUserId: req.id, currentUserId: user.id)
                                    await MainActor.run {
                                        user.outgoingRequests.removeAll { $0 == req.id }
                                        loadFriendData()
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .controlSize(.small)
                        }
                    }
                }
            }
 
            if incomingProfiles.isEmpty && outgoingProfiles.isEmpty {
                Text("No pending requests.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
    }
 
    private func loadFriendData() {
        Task {
            let fetched = await FirestoreManager.shared.fetchUsers(byIds: user.friends)
 
            // Blocked users never show up in Friends or Pending, even if a
            // stale request still exists for them somewhere.
            let blocked = Set(user.blockedUsers)
 
            var incomingData: [(id: String, name: String, profilePic: String)] = []
            for id in user.incomingRequests where !blocked.contains(id) {
                if let profile = await FirestoreManager.shared.fetchFriendProfile(userId: id) {
                    incomingData.append((id: id, name: profile.username, profilePic: profile.profilePicture))
                }
            }
 
            var outgoingData: [(id: String, name: String, profilePic: String)] = []
            for id in user.outgoingRequests where !blocked.contains(id) {
                if let profile = await FirestoreManager.shared.fetchFriendProfile(userId: id) {
                    outgoingData.append((id: id, name: profile.username, profilePic: profile.profilePicture))
                }
            }
 
            await MainActor.run {
                self.friendObjects = fetched.filter { !blocked.contains($0.id) }
                self.incomingProfiles = incomingData
                self.outgoingProfiles = outgoingData
            }
        }
    }
}
 
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
 
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
 
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
 
struct AddFriendSheet: View {
    @ObservedObject var user: User
    @Binding var isPresented: Bool
 
    @State private var searchUsername = ""
    @State private var searchResult: (id: String, name: String, profilePic: String)? = nil
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var requestSent = false
    @State private var isUnblocking = false
    @FocusState private var isSearchFieldFocused: Bool
 
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter exact username", text: $searchUsername)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .focused($isSearchFieldFocused)
 
                Button("Search") {
                    Task {
                        isLoading = true
                        errorMessage = nil
                        searchResult = nil
                        requestSent = false
 
                        let result = await FirestoreManager.shared.findUserByUsername(searchUsername)
 
                        // Check whether the person we found has blocked US —
                        // this only lives on their own document, so it has
                        // to be checked here rather than against anything on
                        // our side. If they have, we show the same "User not
                        // found" message as a real miss, so a blocked person
                        // can't tell they've been blocked.
                        var weAreBlockedByResult = false
                        if let result, result.id != user.id {
                            if let doc = try? await Firestore.firestore().collection("users").document(result.id).getDocument(),
                               let theirBlockedUsers = doc.data()?["blocked_users"] as? [String] {
                                weAreBlockedByResult = theirBlockedUsers.contains(user.id)
                            }
                        }
 
                        await MainActor.run {
                            isLoading = false
                            if let result = result, !weAreBlockedByResult {
                                if result.id == user.id {
                                    errorMessage = "You cannot add yourself."
                                } else if user.blockedUsers.contains(result.id) {
                                    // Show the card with an Unblock option instead
                                    // of an error — this is the only way to undo a
                                    // block in the app.
                                    searchResult = result
                                } else if user.friends.contains(result.id) {
                                    errorMessage = "You are already friends with this user."
                                } else if user.outgoingRequests.contains(result.id) {
                                    errorMessage = "Friend request already sent."
                                } else if user.incomingRequests.contains(result.id) {
                                    errorMessage = "This user has already sent you a request! Check your pending tab."
                                } else {
                                    searchResult = result
                                }
                            } else {
                                errorMessage = "User not found."
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
 
                if isLoading {
                    ProgressView()
                }
 
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
 
                if let result = searchResult {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            if result.profilePic.hasPrefix("http") {
                                AsyncImage(url: URL(string: result.profilePic)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            } else if let data = Data(base64Encoded: result.profilePic),
                                      let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Circle().fill(Color(.systemGray5)))
                                    .clipShape(Circle())
                            }
 
                            Text(result.name)
                                .font(.headline)
 
                            Spacer()
                        }
 
                        if user.blockedUsers.contains(result.id) {
                            Button {
                                Task { await unblockUser(result.id) }
                            } label: {
                                HStack {
                                    if isUnblocking {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "hand.raised.slash.fill")
                                        Text("Unblock")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .disabled(isUnblocking)
                        } else if requestSent {
                            Text("Sent")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                        } else {
                            Button {
                                Task {
                                    await FirestoreManager.shared.sendFriendRequest(targetUserId: result.id, currentUserId: user.id)
                                    await MainActor.run {
                                        if !user.outgoingRequests.contains(result.id) {
                                            user.outgoingRequests.append(result.id)
                                        }
                                        requestSent = true
                                    }
                                }
                            } label: {
                                Text("Add Friend")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
 
                Spacer()
            }
            .navigationTitle("Add Friend")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isSearchFieldFocused = false
                    }
                }
            }
        }
    }
 
    private func unblockUser(_ blockedId: String) async {
        isUnblocking = true
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(user.id).updateData([
                "blocked_users": FieldValue.arrayRemove([blockedId])
            ])
            await MainActor.run {
                user.blockedUsers.removeAll { $0 == blockedId }
                isUnblocking = false
                // Refresh the card so it now shows "Add Friend" instead.
                searchResult = searchResult
            }
        } catch {
            await MainActor.run {
                isUnblocking = false
                errorMessage = "Couldn't unblock this user right now. Please try again."
            }
        }
    }
}
#Preview {
    NavigationView {
        FriendsListView(user: {
            let mockUser = User()
            mockUser.id = "mockUserId"
            mockUser.friends = []
            mockUser.incomingRequests = []
            mockUser.outgoingRequests = []
            return mockUser
        }())
    }
}
 

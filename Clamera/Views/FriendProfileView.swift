//
//  FriendProfileView.swift
//  Clamera
//
//  Created by Isaac Clavijo on 8/31/26.
//
 
import SwiftUI
import FirebaseFirestore
 
struct FriendProfileView: View {
    let friendId: String
 
    @EnvironmentObject var user: User
    @Environment(\.dismiss) var dismiss
 
    @State private var friendUser: User?
    @State private var isLoading = true
    @State private var showRemoveConfirmation = false
    @State private var showBlockConfirmation = false
    @State private var showGiftSheet = false
    @State private var showReportSheet = false
    @State private var blockErrorMessage: String?
 
    private let maxContentWidth: CGFloat = 540
 
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading profile...")
            } else if let friendUser {
                ScrollView {
                    VStack(spacing: 28) {
 
                        // MARK: - Profile Picture & Username
                        VStack(spacing: 12) {
                            profileImageView(friendUser: friendUser)
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 4))
                                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
 
                            Text(friendUser.username)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 24)
 
                        // MARK: - Filtered Stats Card
                        VStack(spacing: 0) {
                            infoRow(title: "Fish Caught", value: "\(friendUser.speciesStore.getFish())")
                            divider()
                            infoRow(title: "Species Caught", value: "\(friendUser.speciesStore.getSpecies())/\(friendUser.speciesStore.speciesList.count)")
                            divider()
                            infoRow(title: "Clam Points", value: "\(friendUser.speciesStore.totalClamPoints)")
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
                        )
 
                        // MARK: - Actions & Navigation Links
                        VStack(spacing: 14) {
 
 
 
                            // Friend's Aquarium Row
                            HStack {
                                Text("\(friendUser.username)'s Aquarium")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                                NavigationLink(destination: friendAquariumDestination(friendUser: friendUser)) {
                                    Text("View")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.cyan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.cyan.opacity(0.12))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
 
                            // Friend's Fish of Fame Row
                            HStack {
                                Text("\(friendUser.username)'s Fish of Fame")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                                NavigationLink(destination: friendFishOfFameDestination(friendUser: friendUser)) {
                                    Text("View")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.cyan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.cyan.opacity(0.12))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
 
                            // Gift Clam Points Row
                            Button {
                                showGiftSheet = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.cyan.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "gift.fill")
                                            .foregroundColor(.cyan)
                                            .font(.system(size: 17, weight: .bold))
                                    }
 
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Gift Clam Points")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text("Send points to \(friendUser.username)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
 
                                    Spacer()
 
                                    Text("Gift")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.cyan)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                            }
                            .buttonStyle(.plain)
 
                            // Report User Row
                            Button {
                                showReportSheet = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.orange.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "flag.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 15, weight: .bold))
                                    }
 
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Report User")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text("Flag inappropriate content or behavior")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
 
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                            }
                            .buttonStyle(.plain)
                        }
 
 
                        // MARK: - Remove / Block Buttons
                        VStack(spacing: 10) {
                            Button(role: .destructive) {
                                showRemoveConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "person.fill.xmark")
                                    Text("Remove Friend")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                                )
                            }
 
                            Button(role: .destructive) {
                                showBlockConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                    Text("Block User")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.red)
                                )
                            }
 
                            if let blockErrorMessage {
                                Text(blockErrorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 6)
 
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
                .sheet(isPresented: $showGiftSheet) {
                    GiftPointsSheet(
                        friendId: friendId,
                        friendUsername: friendUser.username
                    ) { giftedAmount in
                        friendUser.speciesStore.totalClamPoints += giftedAmount
                    }
                    .environmentObject(user)
                }
                .sheet(isPresented: $showReportSheet) {
                    ReportUserSheet(
                        reportedUserId: friendId,
                        reportedUsername: friendUser.username,
                        reporterId: user.id
                    )
                }
            } else {
                Text("Failed to load friend's profile.")
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(.systemGroupedBackground))
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
        .confirmationDialog(
            "Block this user? They won't be able to find your profile, send you a friend request, or message you. This also removes them as a friend if they currently are one.",
            isPresented: $showBlockConfirmation,
            titleVisibility: .visible
        ) {
            Button("Block User", role: .destructive) {
                Task { await blockUser() }
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
 
    // MARK: - Block Action
    private func blockUser() async {
        let db = Firestore.firestore()
        do {
            // Also clean up any friend relationship / pending requests in
            // both directions so a block always wins over a stale request.
            try await db.collection("users").document(user.id).updateData([
                "blocked_users": FieldValue.arrayUnion([friendId]),
                "friends": FieldValue.arrayRemove([friendId]),
                "incoming_requests": FieldValue.arrayRemove([friendId]),
                "outgoing_requests": FieldValue.arrayRemove([friendId])
            ])
            await MainActor.run {
                if !user.blockedUsers.contains(friendId) {
                    user.blockedUsers.append(friendId)
                }
                user.friends.removeAll { $0 == friendId }
                user.incomingRequests.removeAll { $0 == friendId }
                user.outgoingRequests.removeAll { $0 == friendId }
                dismiss()
            }
        } catch {
            await MainActor.run {
                blockErrorMessage = "Couldn't block this user right now. Please try again."
            }
        }
    }
 
    // MARK: - Profile Image Helper
    @ViewBuilder
    private func profileImageView(friendUser: User) -> some View {
        if friendUser.profilePicture.hasPrefix("http") {
            AsyncImage(url: URL(string: friendUser.profilePicture)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
        } else if let data = Data(base64Encoded: friendUser.profilePicture),
                  let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray.opacity(0.6))
                .background(Circle().fill(Color(.systemGray5)))
        }
    }
 
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .bold()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
 
    private func divider() -> some View {
        Divider()
            .padding(.horizontal, 16)
    }
 
    // MARK: - Navigation Destinations
    @ViewBuilder
    private func friendAquariumDestination(friendUser: User) -> some View {
        GeometryReader { proxy in
            AquariumView(showBottomBar: .constant(false), allowEditing: false)
                .environmentObject(friendUser)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("\(friendUser.username)'s Aquarium")
        .navigationBarTitleDisplayMode(.inline)
    }
 
    @ViewBuilder
    private func friendFishOfFameDestination(friendUser: User) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                if !friendUser.fishOfFamePosts.isEmpty {
                    ForEach(friendUser.fishOfFamePosts) { post in
                        VStack(alignment: .leading, spacing: 12) {
                            if post.photo.hasPrefix("http") {
                                AsyncImage(url: URL(string: post.photo)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 240)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: 380)
                                .aspectRatio(16/10, contentMode: .fit)
                                .background(Color.cyan.opacity(0.1))
                                .cornerRadius(16)
                                .clipped()
                            } else {
                                Image(fishPhoto: post.photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(maxHeight: 380)
                                    .aspectRatio(16/10, contentMode: .fit)
                                    .background(Color.cyan.opacity(0.1))
                                    .cornerRadius(16)
                                    .clipped()
                            }
 
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.speciesName.capitalized)
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
 
                                if !post.caption.isEmpty {
                                    Text(post.caption)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.bottom, 4)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(22)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No Fish of Fame posts yet.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding(16)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("\(friendUser.username)'s Fish of Fame")
        .background(Color(.systemGroupedBackground))
    }
}
 
// MARK: - Gift Points Sheet
struct GiftPointsSheet: View {
    @EnvironmentObject var currentUser: User
    @Environment(\.dismiss) private var dismiss
 
    let friendId: String
    let friendUsername: String
    var onGiftComplete: ((Int) -> Void)?
 
    @State private var amountText: String = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @FocusState private var isAmountFieldFocused: Bool
 
    private var amount: Int {
        Int(amountText.filter { $0.isNumber }) ?? 0
    }
 
    private var canSend: Bool {
        amount > 0 && amount <= currentUser.speciesStore.totalClamPoints && !isSending
    }
 
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
 
                // Header Icon
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.12))
                        .frame(width: 80, height: 80)
 
                    Image(systemName: "gift.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.cyan)
                }
                .padding(.top, 24)
 
                VStack(spacing: 6) {
                    Text("Gift Clam Points")
                        .font(.title2.bold())
 
                    Text("Send points to \(friendUsername) to help them unlock shop items and fish.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
 
                // Balance Indicator
                HStack(spacing: 6) {
                    Image(systemName: "circle.circle.fill")
                        .foregroundColor(.cyan)
                    Text("Your Balance: \(currentUser.speciesStore.totalClamPoints) Clam Points")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color(.secondarySystemFill))
                .clipShape(Capsule())
 
                // Amount Input
                VStack(spacing: 12) {
                    TextField("0", text: $amountText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 44, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(height: 64)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(18)
                        .focused($isAmountFieldFocused)
 
                    // Preset increment chips
                    HStack(spacing: 8) {
                        ForEach([25, 50, 100, 250], id: \.self) { preset in
                            Button("+\(preset)") {
                                let currentVal = Int(amountText.filter { $0.isNumber }) ?? 0
                                amountText = "\(min(currentVal + preset, currentUser.speciesStore.totalClamPoints))"
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.cyan)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.cyan.opacity(0.12))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
 
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
 
                Spacer()
 
                Button {
                    Task {
                        await sendGift()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSending {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Send \(amount > 0 ? "\(amount) " : "")Points")
                                .bold()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(canSend ? Color.cyan : Color.gray.opacity(0.4))
                    .cornerRadius(18)
                    .shadow(color: canSend ? Color.cyan.opacity(0.3) : .clear, radius: 6, y: 3)
                }
                .disabled(!canSend)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isAmountFieldFocused = false
                    }
                }
            }
            .alert("Gift Sent!", isPresented: $showSuccessAlert) {
                Button("Done") {
                    onGiftComplete?(amount)
                    dismiss()
                }
            } message: {
                Text("You sent \(amount) Clam Points to \(friendUsername)!")
            }
        }
    }
 
    private func sendGift() async {
        isSending = true
        errorMessage = nil
 
        do {
            try await FirestoreManager.shared.giftClamPoints(
                from: currentUser,
                toRecipientId: friendId,
                amount: amount
            )
            isSending = false
            showSuccessAlert = true
        } catch {
            isSending = false
            errorMessage = error.localizedDescription
        }
    }
}
 
// MARK: - Report User Sheet
struct ReportUserSheet: View {
    @Environment(\.dismiss) private var dismiss
 
    let reportedUserId: String
    let reportedUsername: String
    let reporterId: String
 
    @State private var selectedReason: String = "Inappropriate content"
    @State private var details: String = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
 
    private let reasons = [
        "Inappropriate content",
        "Harassment or bullying",
        "Spam",
        "Fake profile",
        "Other"
    ]
 
    var body: some View {
        NavigationStack {
            Form {
                Section("Why are you reporting \(reportedUsername)?") {
                    Picker("Reason", selection: $selectedReason) {
                        ForEach(reasons, id: \.self) { reason in
                            Text(reason).tag(reason)
                        }
                    }
                    .pickerStyle(.inline)
                }
 
                Section("Additional details (optional)") {
                    TextField("Tell us more...", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }
 
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationTitle("Report User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submitReport() }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .alert("Report Submitted", isPresented: $showSuccessAlert) {
                Button("Done") { dismiss() }
            } message: {
                Text("Thanks for letting us know. Our team will review this report.")
            }
        }
    }
 
    private func submitReport() async {
        isSubmitting = true
        errorMessage = nil
        let db = Firestore.firestore()
        do {
            try await db.collection("reports").addDocument(data: [
                "reportedUserId": reportedUserId,
                "reportedUsername": reportedUsername,
                "reporterId": reporterId,
                "reason": selectedReason,
                "details": details,
                "timestamp": FieldValue.serverTimestamp(),
                "status": "pending"
            ])
            await MainActor.run {
                isSubmitting = false
                showSuccessAlert = true
            }
        } catch {
            await MainActor.run {
                isSubmitting = false
                errorMessage = "Couldn't submit report. Please try again."
            }
        }
    }
}
 
#Preview {
    NavigationView {
        FriendProfileView(friendId: "sample_id")
            .environmentObject(User())
    }
}
 

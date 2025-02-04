//
//  ProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@Observable @MainActor
final class ProfileViewModel {

    var user: DBUser? = nil
    var requestCount: Int = 0
    var isFriend: Bool?
    var requestSent: Bool?
    var requestedMe: Bool?
    var targetUserColor: Color?
    var target: Color?
    let targetUserId: String
    var isPressing = false
    var pressStartTime: Date?
    var tickleString: String = "Tickle"

    init(targetUserId: String, targetUserColor: Color?) {
        self.targetUserId = targetUserId
        self.targetUserColor = targetUserColor
    }

    func attachUserListener(userId: String) {
        Firestore.firestore().collection("users").document(userId).addSnapshotListener({ [weak self] documentSnapshot, error in
            guard let self = self else {
                print("attachUserListener: weak self no reference")
                return
            }
            guard let document = documentSnapshot else {
                print("Error fetching query: \(error)")
                return
            }
            guard let user = try? document.data(as: DBUser.self) else {
                print("Failed to get user")
                return
            }
            self.user = user
        })
    }
    
    func loadTargetUser(targetUserId: String) async throws {

        user = try await UserManager.shared.getUser(userId: targetUserId)
        targetUserColor = Color.fromString(name: user?.userColor ?? "gray")
    }

    func removeFriend(friendUserId: String) {
        guard !friendUserId.isEmpty else { return }
        isFriend = false
        requestSent = false

        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched

            let authDataResultUserId = try AuthenticationManager.shared
                .getAuthenticatedUser().uid

            guard authDataResultUserId != friendUserId else { return }

            try? await UserManager.shared.removeFriend(
                userId: authDataResultUserId, friendUserId: friendUserId)

        }
    }

    func sendFriendRequest(friendUserId: String) {

        guard !friendUserId.isEmpty else { return }
        isFriend = false
        requestSent = true
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched

            let authDataResultUserId = try AuthenticationManager.shared
                .getAuthenticatedUser().uid

            guard authDataResultUserId != friendUserId else { return }

            try? await UserManager.shared.sendFriendRequest(
                userId: authDataResultUserId, friendUserId: friendUserId)

        }
    }

    func unsendFriendRequest(friendUserId: String) {

        guard !friendUserId.isEmpty else { return }
        isFriend = false
        requestSent = false
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched

            let authDataResultUserId = try AuthenticationManager.shared
                .getAuthenticatedUser().uid

            guard authDataResultUserId != friendUserId else { return }

            try? await UserManager.shared.unsendFriendRequest(
                userId: authDataResultUserId, friendUserId: friendUserId)
        }
    }

    func acceptFriendRequest(friendUserId: String) {

        guard !friendUserId.isEmpty else { return }
        isFriend = true
        requestSent = false
        Task {
            //loading like this becasuse this viewModel User changes depending on if its current user or a user thats searched

            let authDataResultUserId = try AuthenticationManager.shared
                .getAuthenticatedUser().uid

            guard authDataResultUserId != friendUserId else { return }

            try? await UserManager.shared.acceptFriendRequest(
                userId: authDataResultUserId, friendUserId: friendUserId)
        }
    }

    func checkFriendshipStatus(currentUserId: String) {
        isFriend = user?.friends?.contains(currentUserId)

    }

    func checkRequestStatus(currentUserId: String) {
            requestSent = user?.incomingFriendRequests?.contains(
                currentUserId)

    }

    func checkRequestedMe(currentUserId: String) {
            requestedMe = user?.outgoingFriendRequests?.contains(
                currentUserId)
    }

}

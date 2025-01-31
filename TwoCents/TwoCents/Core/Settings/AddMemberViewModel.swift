//
//  CreateProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import PhotosUI
import SwiftUI

@Observable @MainActor
final class AddMemberViewModel {

    let spaceId: String
    var name = ""
    var user: DBUser? = nil
    var allFriends: [DBUser] = []
    var selectedMembers: [DBUser] = []
    var selectedMembersUserId: [String] = []
    var url: URL? = nil
    var selectedPhoto: PhotosPickerItem? = nil

    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared
            .getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(
            userId: authDataResult.uid)
    }

    func saveSpace(spaceId: String, members: [String]) async throws {
        // Ensure the current user is present in the new selection
        if let user = user, !selectedMembersUserId.contains(user.userId) {
            selectedMembersUserId.append(user.userId)
        }

        // "newlyAdded" = present in "selectedMembersUserId" but NOT in "members"
        let newlyAdded = selectedMembersUserId.filter { !members.contains($0) }

        // "removed" = present in "members" but NOT in "selectedMembersUserId"
        let removed = members.filter { !selectedMembersUserId.contains($0) }

        // Invite newly added members
        try await SpaceManager.shared.inviteSpaceMembers(
            spaceId: spaceId,
            members: newlyAdded
        )
        // Remove members that no longer appear in the new list
        try await SpaceManager.shared.removeSpaceMembers(
            spaceId: spaceId,
            members: removed
        )
    }


    func saveProfileImage(item: PhotosPickerItem) {

        print("here2")

        Task {
            print("here1")
            guard let data = try await item.loadTransferable(type: Data.self)
            else { return }

            print("here")

            let (path, name) = try await StorageManager.shared
                .saveSpaceProfilePic(data: data, spaceId: spaceId)
            print("Saved Image")
            print(path)
            print(name)
            let url = try await StorageManager.shared.getURLForImage(path: path)
            print(url)
            try await SpaceManager.shared.updateSpaceProfileImage(
                spaceId: spaceId, url: url.absoluteString, path: path)

        }

    }

    func getAllFriends(userId: String) async throws {
        self.allFriends = try await UserManager.shared.getAllFriends(
            userId: userId)
    }

    func getSelectedMembers(space: DBSpace?) async throws {

        guard let space else { return }

        //append Members DBUser info
        self.selectedMembers = try await UserManager.shared.getMembersInfo(
            members: (space.members)!)

        //append Members user ID
        if let membersId = space.members {
            self.selectedMembersUserId.append(contentsOf: membersId)
        }

        //remove member from friends
        for member in selectedMembers {

            // Remove user from members UID array

            allFriends.removeAll { friend in
                friend.id == member.id
            }

        }

    }

    func filterFriends() -> [DBUser] {
        return allFriends.filter { friend in
            !selectedMembers.contains { $0.id == friend.id }  // Assuming `id` is the unique identifier for DBUser
        }
    }

    func addMember(friend: DBUser) {

        // Check if the user is already in the selected members array
        if !selectedMembers.contains(where: { $0.userId == friend.userId }) {
            // Remove user from all friends array
            allFriends.removeAll { user in
                return user.userId == friend.userId
            }

            // Add user to selected member array
            selectedMembers.append(friend)

            // Add user to selected member UserID array
            selectedMembersUserId.append(friend.userId)
        }
    }

    func removeMember(friend: DBUser) {

        // Check if the user is already in the selected members array
        if selectedMembers.contains(where: { $0.userId == friend.userId }) {
            // Remove user from members array
            selectedMembers.removeAll { user in
                return user.userId == friend.userId
            }

            // Remove user from members UID array
            selectedMembersUserId.removeAll { user in
                return user == friend.userId
            }

            // Add user to all friends array
            allFriends.append(friend)
        }
    }

    func getUserColor(userColor: String) -> Color {
        Color.fromString(name: userColor)
    }

}

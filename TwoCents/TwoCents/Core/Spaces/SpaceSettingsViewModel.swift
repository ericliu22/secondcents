//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

@Observable @MainActor
final class SpaceSettingsViewModel {

    var allMembers: [DBUser] = []
    var spaceId: String
    var isShowingAddMember: Bool = false
    var linkMessage: String = "Fetching Invite Link..."
    var fetchedInvite: Bool = false
    var showingAlert: Bool = false
    var spaceLink: String?

    init(spaceId: String) {
        self.spaceId = spaceId
        getInviteLink()
    }
    
    func getInviteLink() {
        Task {
            guard let link = try? await SpaceManager.shared.generateSpaceLink(spaceId: spaceId) else {
                linkMessage = "Failed to generate invite link"
                return
            }
            spaceLink = link
            linkMessage = "Copy Inite Link"
            fetchedInvite = true
        }
    }

    func getMembersInfo(space: DBSpace?) async throws {

        guard let space else { return }

        self.allMembers = try await UserManager.shared.getMembersInfo(
            members: (space.members)!)
    }

    //Leave Space (REMOVE YOURSELF)
    func removeSelf(spaceId: String) async throws {

        let selfId = try AuthenticationManager.shared.getAuthenticatedUser().uid
        try await SpaceManager.shared.removeUserFromSpace(
            userId: selfId, spaceId: spaceId)
    }

    func removeUser(userId: String, spaceId: String) async throws {

        try await SpaceManager.shared.removeUserFromSpace(
            userId: userId, spaceId: spaceId)

    }

    func deleteSpace(spaceId: String) async throws {

        try await SpaceManager.shared.deleteSpace(spaceId: spaceId)

    }

    func getUserColor(userColor: String) -> Color {

        return Color.fromString(name: userColor)

    }

    func leaveSpaceButton() {
            if allMembers.count <= 3 {
                Task {
                    try? await deleteSpace(
                        spaceId: spaceId)
                }
            } else {
                Task {
                    try? await removeSelf(
                        spaceId: spaceId)
                }
            }
    }

}

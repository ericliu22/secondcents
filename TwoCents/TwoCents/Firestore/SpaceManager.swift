//
//  UserManager.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct DBSpace: Identifiable, Codable, Hashable {
    var id: String { spaceId }
    let spaceId: String
    let dateCreated: Date
    let name: String?
    let emoji: String?
    let profileImagePath: String?
    let profileImageUrl: String?
    let members: [String]?
    let admins: [String]?
    var privateKey: String?
    var spaceToken: String?
    var nextWidgetX: CGFloat?
    var nextWidgetY: CGFloat?

    init(
        spaceId: String,
        dateCreated: Date? = nil,
        name: String? = nil,
        emoji: String? = nil,
        profileImagePath: String? = nil,
        profileImageUrl: String? = nil,
        members: [String]? = nil
    ) {
        self.spaceId = spaceId
        self.dateCreated = Date()
        self.name = name
        self.emoji = emoji
        self.profileImagePath = profileImagePath
        self.profileImageUrl = profileImageUrl
        self.members = members
        self.nextWidgetX = 0
        self.nextWidgetY = 0
        if let userId = try? AuthenticationManager.shared.getAuthenticatedUser()
            .uid
        {
            self.admins = [userId]
        } else {
            self.admins = []
        }
    }

}

let spaceCollection = Firestore.firestore().collection("spaces")

final class SpaceManager {

    let FIRST_X: CGFloat = 720
    let FIRST_Y: CGFloat = 720
    let LAST_X: CGFloat = 2340
    let LAST_Y: CGFloat = 2340

    @MainActor static let shared = SpaceManager()

    private init() {}

    //so you dont have to type this many times... creates cleaner code

    private func spaceDocument(spaceId: String) -> DocumentReference {
        spaceCollection.document(spaceId)
    }

    func createNewSpace(space: DBSpace) async throws {
        try spaceDocument(spaceId: space.spaceId).setData(
            from: space, merge: false)
    }

    func deleteSpace(spaceId: String) async throws {
        try await spaceDocument(spaceId: spaceId).delete()
    }

    func removeUserFromSpace(userId: String, spaceId: String) async throws {

        //put friend uid in user database
        let newArray: [String: Any] = [
            "members": FieldValue.arrayRemove([userId])

        ]
        try await spaceDocument(spaceId: spaceId).updateData(newArray)

    }

    func moveWidget(spaceId: String, widgetId: String, x: CGFloat, y: CGFloat) {
        spaceDocument(spaceId: spaceId).collection("widgets").document(widgetId)
            .updateData([
                "x": x,
                "y": y,
            ])
    }

    func inviteSpaceMembers(spaceId: String, members: [String]) async throws {

        for member in members {
            do {
                try await sendSpaceRequest(spaceId: spaceId, userId: member)
            } catch {
                print("Failed to send space request")
            }
        }
    }
    
    func removeSpaceMembers(spaceId: String, members: [String]) async throws {
        try await spaceDocument(spaceId: spaceId).updateData([
            "members": FieldValue.arrayRemove(members)
        ])
    }

    func getSpace(spaceId: String) async throws -> DBSpace {

        try await spaceDocument(spaceId: spaceId).getDocument(as: DBSpace.self)

    }

    func getWidget(spaceId: String, widgetId: String) async throws
        -> CanvasWidget
    {

        try await spaceDocument(spaceId: spaceId).collection("widgets")
            .document(widgetId).getDocument(as: CanvasWidget.self)

    }

    func updateSpaceProfileImage(spaceId: String, url: String, path: String)
        async throws
    {
        let data: [String: Any] = [
            "profileImagePath": path,
            "profileImageUrl": url,
        ]

        try await spaceDocument(spaceId: spaceId).updateData(data)
    }

    func formatWidget(widget: CanvasWidget) -> CanvasWidget {
        //Need to copy to variable before uploading (something about actor-isolate whatever)
        var uploadWidget: CanvasWidget = widget
        //ensure shits are right dimensions (depreacated)
        return uploadWidget
    }

    func uploadWidget(spaceId: String, widget: CanvasWidget) {
        let uploadWidget = formatWidget(widget: widget)
        do {
            let uid = try AuthenticationManager.shared.getAuthenticatedUser()
                .uid
            Task {
                let user = try await UserManager.shared.getUser(userId: uid)
                guard let name = user.name else {
                    print("Failed to get username")
                    return
                }
                try spaceDocument(spaceId: spaceId)
                    .collection("widgets")
                    .document(uploadWidget.id.uuidString)
                    .setData(from: uploadWidget)
                try await widgetNotification(
                    spaceId: spaceId, name: name, widget: widget)
                await widgetUnread(
                    spaceId: spaceId, widgetId: widget.id.uuidString)
            }
        } catch {
            print("Some shit fucked up")
        }

    }
    
    func inviteMember(spaceId: String, userId: String ) async throws {
        try await sendSpaceRequest(spaceId: spaceId, userId: userId)
    }

    func generateSpaceLink(spaceId: String) async throws -> String {

        let spaceToken = try await fetchSpaceToken(spaceId: spaceId)
        return "https://api.twocentsapp.com/app/invite/\(spaceId)/\(spaceToken)"

    }

    func removeWidget(spaceId: String, widget: CanvasWidget) {
        spaceDocument(spaceId: spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
            .delete()
    }

    func changeWidgetSize(
        spaceId: String, widgetId: String, widthMultiplier: Int,
        heightMultiplier: Int
    ) {
        let width: CGFloat =
            TILE_SIZE * CGFloat(widthMultiplier)
            + (max(CGFloat(widthMultiplier - 1), 0) * TILE_SPACING)
        let height: CGFloat =
            TILE_SIZE * CGFloat(heightMultiplier)
            + (max(CGFloat(heightMultiplier - 1), 0) * TILE_SPACING)
    }

    func getMultipliedSize(widthMultiplier: Int, heightMultiplier: Int) -> (
        CGFloat, CGFloat
    ) {
        let width: CGFloat =
            TILE_SIZE * CGFloat(widthMultiplier)
            + (max(CGFloat(widthMultiplier - 1), 0) * TILE_SPACING)
        let height: CGFloat =
            TILE_SIZE * CGFloat(heightMultiplier)
            + (max(CGFloat(heightMultiplier - 1), 0) * TILE_SPACING)

        return (width, height)
    }

    private func setSize(
        spaceId: String, widgetId: String, width: CGFloat, height: CGFloat
    ) {
        spaceDocument(spaceId: spaceId)
            .collection("widgets")
            .document(widgetId)
            .updateData([
                "width": width,
                "height": height,
            ])
    }
}

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

    func updateSpaceMembers(spaceId: String, members: [String]) async throws {

        //put friend uid in user database
        let newArray: [String: Any] = [
            "members": members

        ]

        try await spaceDocument(spaceId: spaceId).updateData(newArray)

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
        //ensure shits are right dimensions
        //uploadWidget.width = TILE_SIZE
        //uploadWidget.height = TILE_SIZE
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

    func moveToEmptySpace(space: DBSpace, widgetId: String) async {
        guard space.nextWidgetX != nil || space.nextWidgetY != nil else {
            let newX = roundToTile(number: FRAME_SIZE / 2)
            let newY = roundToTile(number: FRAME_SIZE / 2)
            moveWidget(
                spaceId: space.spaceId, widgetId: widgetId, x: newX, y: newY)
            await setNextWidgetSpot(
                spaceId: space.spaceId, startingX: newX, startingY: newY)
            return
        }

        if !withinBounds(x: space.nextWidgetX!, y: space.nextWidgetY!) {
            let newX = roundToTile(number: FRAME_SIZE / 2)
            let newY = roundToTile(number: FRAME_SIZE / 2)
            moveWidget(
                spaceId: space.spaceId, widgetId: widgetId, x: newX, y: newY)
            await setNextWidgetSpot(
                spaceId: space.spaceId, startingX: newX, startingY: newY)
            return
        }

        //We already checked for null you cunt stop making me exclamation mark
        guard
            let empty = try? await spotEmpty(
                spaceId: space.spaceId, x: space.nextWidgetX!,
                y: space.nextWidgetY!)
        else {
            return
        }

        if !empty {
            await setNextWidgetSpot(
                spaceId: space.spaceId, startingX: space.nextWidgetX!,
                startingY: space.nextWidgetY!)
        }

        moveWidget(
            spaceId: space.spaceId, widgetId: widgetId, x: space.nextWidgetX!,
            y: space.nextWidgetY!)
        await setNextWidgetSpot(
            spaceId: space.spaceId, startingX: space.nextWidgetX!,
            startingY: space.nextWidgetY!)
    }

    func generateSpaceLink(spaceId: String) async throws -> String {

        let spaceToken = try await fetchSpaceToken(spaceId: spaceId)
        return "https://api.twocentsapp.com/app/invite/\(spaceId)/\(spaceToken)"

    }

    func setNextWidgetSpot(
        spaceId: String, startingX: CGFloat, startingY: CGFloat
    ) async {
        guard
            let (newX, newY) = try? await findNextSpot(
                spaceId: spaceId, startingX: startingX, startingY: startingY)
        else {
            print("Failed to find next spot")
            return
        }

        //If the function gets here anyways it should work
        //Unless someone deletes the space as this happens; Rare but we don't care
        try! await spaceDocument(spaceId: spaceId).updateData([
            "nextWidgetX": newX,
            "nextWidgetY": newY,
        ])
    }

    enum LoopLimit: Error {
        case runtimeError(String)
    }

    private func findNextSpot(
        spaceId: String, startingX: CGFloat, startingY: CGFloat
    ) async throws -> (CGFloat, CGFloat) {
        //@TODO: Stop execution if we reach maximum number of widgets on canvas?? (Design choice here)
        //This is abitrary number didn't actually calculate how many widgets are possible on the canvas
        let LOOP_LIMIT: Int = 100
        var currentX: CGFloat = startingX
        var currentY: CGFloat = startingY

        var count: Int = 0
        while count < LOOP_LIMIT {
            let spaceAvailable: Bool = try await spotEmpty(
                spaceId: spaceId, x: currentX, y: currentY)
            if spaceAvailable && withinBounds(x: currentX, y: currentY) {
                break
            }

            if currentX + WIDGET_SPACING > LAST_X {
                currentX = FIRST_X
                currentY += WIDGET_SPACING
            } else if currentY + WIDGET_SPACING > LAST_Y {
                currentX = FIRST_X
                currentY = FIRST_Y
            } else {
                currentX += WIDGET_SPACING
            }
            //Optional if we wanna be really safe
            currentX = roundToTile(number: currentX)
            currentY = roundToTile(number: currentY)
            count += 1
        }
        //Highly Questionable while(true); We set a hard coded limit in case things go to shit
        if count == LOOP_LIMIT {
            throw LoopLimit.runtimeError("findNextSpot: Loop reached limit")
        }
        return (currentX, currentY)
    }

    private func spotEmpty(spaceId: String, x: CGFloat, y: CGFloat) async throws
        -> Bool
    {
        return try await spaceDocument(spaceId: spaceId).collection("widgets")
            .whereField("x", isEqualTo: x)
            .whereField("y", isEqualTo: y)
            .limit(to: 1)
            .getDocuments()
            .isEmpty
    }

    private func withinBounds(x: CGFloat, y: CGFloat) -> Bool {
        return FIRST_X < x && x < LAST_X && FIRST_Y < y && y < LAST_Y
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

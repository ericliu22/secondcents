//
//  UserManager.swift
//  TwoCents
//
//  Created by jonathan on 8/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct DBSpace: Identifiable, Codable, Hashable {
    var id: String { spaceId }
    let spaceId: String
    let dateCreated: Date
    let name: String?
    let emoji: String?
    let profileImagePath: String?
    let profileImageUrl: String?
    let members: Array<String>?
    var nextWidgetX: CGFloat?
    var nextWidgetY: CGFloat?
 
    
    
    init(
        spaceId: String,
        dateCreated: Date? = nil,
        name: String? = nil,
        emoji: String? = nil,
        profileImagePath: String? = nil,
        profileImageUrl: String? = nil,
        members: Array<String>? = nil
       
    )
    {
        self.spaceId = spaceId
        self.dateCreated = Date()
        self.name = name
        self.emoji = emoji
        self.profileImagePath = profileImagePath
        self.profileImageUrl = profileImageUrl
        self.members = members
        self.nextWidgetX = 0
        self.nextWidgetY = 0
    }
    
    
}


final class SpaceManager{
    
    let FIRST_X: CGFloat = 360
    let FIRST_Y: CGFloat = 360
    let LAST_X: CGFloat = 1180
    let LAST_Y: CGFloat = 1180

    static let shared = SpaceManager()
    private init() { }
    
    //so you dont have to type this many times... creates cleaner code
    private let spaceCollection = Firestore.firestore().collection("spaces")
    
    private func spaceDocument(spaceId: String) -> DocumentReference {
        spaceCollection.document(spaceId)
        
    }
    

    
    func createNewSpace(space: DBSpace) async throws {

        try spaceDocument(spaceId: space.spaceId).setData(from: space, merge: false)
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
        spaceDocument(spaceId: spaceId).collection("widgets").document(widgetId).updateData([
            "x": x,
            "y": y
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
    
    
    
    func getWidget(spaceId: String, widgetId: String) async throws -> CanvasWidget {

        try await spaceDocument(spaceId: spaceId).collection("widgets").document(widgetId).getDocument(as: CanvasWidget.self)
        
    }
    
    func updateSpaceProfileImage(spaceId: String, url: String, path: String) async throws {
        let data: [String: Any] = [
            "profileImagePath": path,
            "profileImageUrl": url
        ]
        
        try await spaceDocument(spaceId: spaceId).updateData(data)
    }
    
    func uploadWidget(spaceId: String, widget: CanvasWidget) {
        do {
            let uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
            try spaceDocument(spaceId: spaceId)
                .collection("widgets")
                .document(widget.id.uuidString)
                .setData(from: widget)
            widgetNotification(spaceId: spaceId, userUID: uid, widget: widget)
        } catch {
            print("Some shit fucked up")
        }
        
        Task {
            guard let space: DBSpace = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
                return
            }
            //Race condition: widgets can overlap if user tries to move a widget while user creates a widget
            //Tbh who cares skill issue
            await moveToEmptySpace(space: space, widgetId: widget.id.uuidString)
        }
    }
    
    func moveToEmptySpace(space: DBSpace, widgetId: String) async {
        guard (space.nextWidgetX != nil || space.nextWidgetY != nil) else {
            moveWidget(spaceId: space.spaceId, widgetId: widgetId, x: roundToTile(number: FRAME_SIZE/2), y: roundToTile(number: FRAME_SIZE/2))
            await setNextWidgetSpot(spaceId: space.spaceId, startingX: roundToTile(number: FRAME_SIZE/2), startingY: roundToTile(number: FRAME_SIZE/2))
            return
        }
        
        //We already checked for null you cunt stop making me exclamation mark
        
        guard let empty = try? await spotEmpty(spaceId: space.spaceId, x: space.nextWidgetX!, y: space.nextWidgetY!) else {
            return
        }
        
        if !empty {
            await setNextWidgetSpot(spaceId: space.spaceId, startingX: space.nextWidgetX!, startingY: space.nextWidgetY!)
        }
        
        moveWidget(spaceId: space.spaceId, widgetId: widgetId, x: space.nextWidgetX!, y: space.nextWidgetY!)
        await setNextWidgetSpot(spaceId: space.spaceId, startingX: space.nextWidgetX!, startingY: space.nextWidgetY!)
    }
    
    func generateSpaceLink(spaceId: String ) -> String {
        return "https://api.twocentsapp.com/app/space/\(spaceId)"
    }
    
    func setNextWidgetSpot(spaceId: String, startingX: CGFloat, startingY: CGFloat) async {
        guard let (newX, newY) = try? await findNextSpot(spaceId: spaceId, startingX: startingX, startingY: startingY) else {
            print("Failed to find next spot")
            return
        }
        
        //If the function gets here anyways it should work
        //Unless someone deletes the space as this happens; Rare but we don't care
        try! await spaceDocument(spaceId: spaceId).updateData([
            "nextWidgetX": newX,
            "nextWidgetY": newY
        ])
    }
    
    enum FuckedLoop: Error {
        case runtimeError(String)
    }
        
    private func findNextSpot(spaceId: String, startingX: CGFloat, startingY: CGFloat) async throws -> (CGFloat, CGFloat){
        //@TODO: Stop execution if we reach maximum number of widgets on canvas?? (Design choice here)
        //This is abitrary number didn't actually calculate how many widgets are possible on the canvas
        let LOOP_LIMIT: Int = 100
        var currentX: CGFloat = startingX
        var currentY: CGFloat = startingY
        
        var count: Int = 0
        while (true || count != LOOP_LIMIT ) {
            if try await spotEmpty(spaceId: spaceId, x: currentX, y: currentY) { break }
            
            
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
            count+=1
        }
        //Highly Questionable while(true); We set a hard coded limit in case things go to shit
        if count == LOOP_LIMIT { throw FuckedLoop.runtimeError("findNextSpot: Loop reached limit") }
        return (currentX, currentY)
    }
    
    private func spotEmpty(spaceId: String, x: CGFloat, y: CGFloat) async throws -> Bool {
        return try await spaceDocument(spaceId: spaceId).collection("widgets")
                .whereField("x", isEqualTo: x)
                .whereField("y", isEqualTo: y)
                .limit(to: 1)
                .getDocuments()
                .isEmpty
    }

    func removeWidget(spaceId: String, widget: CanvasWidget) {
          spaceDocument(spaceId: spaceId)
                .collection("widgets")
                .document(widget.id.uuidString)
                .delete()
    }
    
    func setImageWidgetPic(spaceId: String, widgetId: String, url: String, path: String) async throws {
        let data: [String: Any] = [
            "ImagePath": path,
            "ImageUrl": url
        ]
        
        try await spaceDocument(spaceId: spaceId).collection("imageWidgets").document(widgetId).setData(data)
    }
    
    
    
}



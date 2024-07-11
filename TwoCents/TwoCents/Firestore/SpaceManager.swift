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

struct DBSpace: Identifiable, Codable{
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

let WIDGET_SPACING: CGFloat = TILE_SIZE + TILE_SPACING

final class SpaceManager{
    
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
            try spaceDocument(spaceId: spaceId)
                .collection("widgets")
                .document(widget.id.uuidString)
                .setData(from: widget)
        } catch {
            print("Some shit fucked up")
        }
        
        Task {
            guard let space: DBSpace = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
                return
            }
            //Race condition: widgets can overlap if user tries to move a widget while user creates a widget
            //Tbh who cares skill issue
            moveWidget(spaceId: spaceId, widgetId: widget.id.uuidString, x: space.nextWidgetX ?? FRAME_SIZE/2, y: space.nextWidgetY ?? FRAME_SIZE/2)
            await setNextWidgetSpot(spaceId: spaceId, startingX: space.nextWidgetX ?? FRAME_SIZE/2, startingY: space.nextWidgetY ?? FRAME_SIZE/2)
        }
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
        var currentX: CGFloat = startingX
        var currentY: CGFloat = startingY
        
        var count: Int = 0
        //Highly Questionable; We set a hard coded limit of 1k in case things go to shit
        while (true || count != 1000) {
            let spotEmpty = try await spaceDocument(spaceId: spaceId).collection("widgets")
                .whereField("x", isEqualTo: currentX)
                .whereField("y", isEqualTo: currentY)
                .limit(to: 1)
                .getDocuments()
                .isEmpty
            if spotEmpty { break }
            
            currentX += WIDGET_SPACING
            currentY += WIDGET_SPACING
            count+=1
        }
        if count == 1000 { throw FuckedLoop.runtimeError("Loop reached 1000") }
        return (currentX, currentY)
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



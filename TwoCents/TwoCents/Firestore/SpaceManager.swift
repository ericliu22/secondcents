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
    
    func moveDatabaseWidget(spaceId: String, widgetId: String, x: CGFloat, y: CGFloat) {
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
    
    //Takes the CanvasWidget class as a parameter, encodes it, then uploads to database
    func uploadWidget(spaceId: String, widget: CanvasWidget) {
        do {
            try spaceDocument(spaceId: spaceId)
                .collection("widgets")
                .document(widget.id.uuidString)
                .setData(from: widget)
        } catch {
            print("Some shit fucked up")
        }
    }
    
    //Update the nextspot
    func setWidgetSpot(spaceId: String) async {
        guard let space = try? await SpaceManager.shared.getSpace(spaceId: spaceId) else {
            print("setWidgetSpot: Failed to get space")
            return
        }
        
        //spaceDocument(spaceId: spaceId).collection("widgets").whereField(<#T##field: String##String#>, arrayContains: <#T##Any#>)
        
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



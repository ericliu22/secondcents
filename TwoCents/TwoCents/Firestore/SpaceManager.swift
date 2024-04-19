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
    
    
    
    func getSpace(spaceId: String) async throws -> DBSpace {

        try await spaceDocument(spaceId: spaceId).getDocument(as: DBSpace.self)
        
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



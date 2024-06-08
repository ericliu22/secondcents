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

struct DBUser: Identifiable, Codable{
    var id: String { userId }
    let userId: String
    let email: String?
   
    let dateCreated: Date?
    let name: String?
    let username: String?
    let profileImagePath: String?
    let profileImageUrl: String?
    let userColor: String?
    let friends: Array<String>?
    let incomingFriendRequests: Array<String>?
    let outgoingFriendRequests: Array<String>?
    let registrationToken: String?
    
    
    
    //create from auth data result
    init(auth: AuthDataResultModel, name: String, username: String) {
        self.userId = auth.uid
        self.email = auth.email
       
        self.dateCreated = Date()
        self.name = name
        self.username = username
        self.profileImagePath = nil
        self.profileImageUrl = nil
        self.userColor = nil
        self.friends = []
        self.incomingFriendRequests = []
        self.outgoingFriendRequests = []
        
    }
    
    
    
    init(
        userId: String,
        email: String? = nil,

        dateCreated: Date? = nil,
        name: String? = nil,
        username: String? = nil,
        profileImagePath: String? = nil,
        profileImageUrl: String? = nil,
        userColor: String? = nil,
        friends: Array<String>? = nil,
        incomingFriendRequests: Array<String>? = nil,
        outgoingFriendRequests: Array<String>? = nil
    )
    {
        self.userId = userId
        self.email = email
    
        self.dateCreated = dateCreated
        self.name = name
        self.username = username
        self.profileImagePath = profileImagePath
        self.profileImageUrl = profileImageUrl
        self.userColor = nil
        self.friends = []
        self.incomingFriendRequests = []
        self.outgoingFriendRequests = []
    }
    
    
}

final class UserManager{
    
    static let shared = UserManager()
    private init() { }
    
    //so you dont have to type this many times... creates cleaner code
    private let userCollection = Firestore.firestore().collection("users")
    private let spaceCollection = Firestore.firestore().collection("spaces")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
        
    }
    
    private func spaceDocument(spaceId: String) -> DocumentReference {
        spaceCollection.document(spaceId)
        
    }
    
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    } ()
//
//
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    } ()
    
    func createNewUser(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    
    
    func getUser(userId: String) async throws -> DBUser {
//        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
        
    }
    
    
    func getAllUsers(userId: String) async throws -> [DBUser]{
        
        let snapshot: QuerySnapshot
        
        snapshot = try await userCollection.whereField("userId", isNotEqualTo: userId).getDocuments()
    
        
        
        var allUsers: [DBUser] = []
        
        
        for document in snapshot.documents{
            
            
            let singleUser = try document.data(as: DBUser.self)
         
            
            allUsers.append(singleUser)
        }
        
        return allUsers
        
    }

    func getAllFriends(userId: String) async throws -> [DBUser]{
        
        let snapshot: QuerySnapshot
       
        snapshot = try await userCollection.whereField("friends", arrayContains: userId).getDocuments()
        
        
        
        var friends: [DBUser] = []
        
        
        for document in snapshot.documents{
            
            
            let friend = try document.data(as: DBUser.self)
         
            
            friends.append(friend)
        }
        
        return friends
        
    }
    
    func getMembersInfo(members: Array<String>) async throws -> [DBUser]{
        
        
        var membersInfo: [DBUser] = []
        
        
        for member in members{
            if let memberInfo = try? await getUser(userId: member) {
                
                membersInfo.append(memberInfo)
            }
        }
        return membersInfo
        
    }
    
   
    
    
    
    
//    func getUser(spaceId: String) async throws -> DBSpace {
////        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
//        try await spaceDocument(spaceId: spaceId).getDocument(as: DBSpace.self)
//        
//    }
    
    func getAllSpaces(userId: String) async throws -> [DBSpace]{
        print("USERID: \(userId)")
      
        let snapshot: QuerySnapshot
       
        snapshot = try await spaceCollection.whereField("members", arrayContains: userId).getDocuments()
        
        
        
        var spaces: [DBSpace] = []
        
       
        for document in snapshot.documents{
            
        
            let space = try document.data(as: DBSpace.self)
            
            spaces.append(space)
        }
        
        return spaces
        
    }
    
    
    
    func getAllRequests(userId: String) async throws -> [DBUser]{
        
        let snapshot: QuerySnapshot
      
        snapshot = try await userCollection.whereField("outgoingFriendRequests", arrayContains: userId).getDocuments()
  
        
        
        var requests: [DBUser] = []
        
        
        for document in snapshot.documents{
            
            
            let request = try document.data(as: DBUser.self)
         
            
            requests.append(request)
        }
        
        return requests
        
    }
    

    
    func updateUserProfileImage(userId: String, url: String, path: String) async throws {
        let data: [String: Any] = [
            "profileImagePath": path,
            "profileImageUrl": url
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    
    func updateUserColor(userId: String, selectedColor: Color) async throws {
        let data: [String: Any] = [
            "userColor": selectedColor.description,
          
        ]
        print("COLOR: \(selectedColor.description)")
        
        try await userDocument(userId: userId).updateData(data)
//        print("Done")
        
    }
    
    
    func addFriend(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "friends": FieldValue.arrayUnion([friendUserId])
          
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "friends": FieldValue.arrayUnion([userId])
          
        ]
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)

        
    }
    
    func removeFriend(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "friends": FieldValue.arrayRemove([friendUserId])
          
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "friends": FieldValue.arrayRemove([userId])
          
        ]
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)

        
    }
    
    
    func acceptFriendRequest(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "incomingFriendRequests": FieldValue.arrayRemove([friendUserId])
          
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "outgoingFriendRequests": FieldValue.arrayRemove([userId])
          
        ]
        
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)

        try? await addFriend(userId: userId, friendUserId: friendUserId)
        
    }
    
    func declineFriendRequest(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "incomingFriendRequests": FieldValue.arrayRemove([friendUserId])
          
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "outgoingFriendRequests": FieldValue.arrayRemove([userId])
          
        ]
        
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)
        
    }
    
    
    
    
    
    
    func sendFriendRequest(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "outgoingFriendRequests": FieldValue.arrayUnion([friendUserId])
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "incomingFriendRequests": FieldValue.arrayUnion([userId])
        ]
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)

        
    }
    
    func unsendFriendRequest(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "outgoingFriendRequests": FieldValue.arrayRemove([friendUserId])
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "incomingFriendRequests": FieldValue.arrayRemove([userId])
        ]
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)

        
    }
    
    
}



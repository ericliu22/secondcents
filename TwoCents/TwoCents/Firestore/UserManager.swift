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
        friends: Array<String>? = nil
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
    }
    
    
}

final class UserManager{
    
    static let shared = UserManager()
    private init() { }
    
    //so you dont have to type this many times... creates cleaner code
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
        
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
    
    //    func createNewUser(auth: AuthDataResultModel) async throws {
    //        print ("create new user func executed")
    //        var userData: [String: Any] = [
    //            "user_id" : auth.uid,
    //            "date_created" : Timestamp(),
    //
    //
    //        ]
    //
    //        if let email = auth.email {
    //            userData["email"] = email
    //        }
    //
    //        if let photoUrl = auth.photoUrl {
    //            userData["photo_url"] = photoUrl
    //        }
    //
    //        try await userDocument(userId: auth.uid).setData(userData, merge: false)
    //
    //
    //    }
    
    
    func getUser(userId: String) async throws -> DBUser {
//        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
        
    }
    
    
    func getAllUsers(userId: String, friendsOnly: Bool) async throws -> [DBUser]{
        
        let snapshot: QuerySnapshot
        if (friendsOnly) {
            snapshot = try await userCollection.whereField("friends", arrayContains: userId).getDocuments()
        } else {
            snapshot = try await userCollection.whereField("userId", isNotEqualTo: userId).getDocuments()
        }
        
        
        var friends: [DBUser] = []
        
        
        for document in snapshot.documents{
            
            
            let friend = try document.data(as: DBUser.self)
         
            
            friends.append(friend)
        }
        
        return friends
        
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
        print(selectedColor.description)
        
        try await userDocument(userId: userId).updateData(data)
//        print("Done")
        
    }
    
    
    func addFriend(userId: String, friendUserId: String) async throws {
        
        
        
        //put friend uid in user database
        let intoUserDatabase: [String: Any] = [
            "friends": [friendUserId]
          
        ]
        try await userDocument(userId: userId).updateData(intoUserDatabase)
        
        
        //put user uid in friend database
        let intoFriendDatabase: [String: Any] = [
            "friends": [userId]
          
        ]
        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)

        
    }
//    
//    func removeFriend(userId: String, friendUserId: String) async throws {
//        
//        
//        
//        //put friend uid in user database
//        let intoUserDatabase: [String: Any] = [
//            "friends": FieldValue.arrayRemove([friendUserId])
//          
//        ]
//        try await userDocument(userId: userId).updateData(intoUserDatabase)
//        
//        
//        //put user uid in friend database
//        let intoFriendDatabase: [String: Any] = [
//            "friends": FieldValue.arrayRemove([userId])
//          
//        ]
//        try await userDocument(userId: friendUserId).updateData(intoFriendDatabase)
//
//        
//    }
//    
    
    
    //
    //    func getUser(userId: String) async throws -> DBUser {
    //        let snapshot = try await userDocument(userId: userId).getDocument()
    //
    //        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
    //            throw URLError(.badServerResponse)
    //        }
    //
    //
    //        let email = data["email"] as? String
    //        let photoUrl = data["photo_url"] as? String
    //        let dateCreated = data["date_created"] as? Date
    //
    //        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
    //    }
    
    
    
    
    
    
    
    //
    //
    //    func updateUser (user: DBUser) async throws {
    //        try userDocument(userId: user.userId).setData(from: user, merge: true, encoder: encoder)
    //    }
    
    
    
}



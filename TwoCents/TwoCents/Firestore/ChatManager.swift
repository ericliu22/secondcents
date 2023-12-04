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


struct DBChat: Identifiable, Codable{
    var id: String { chatId }
    let chatId: String
    let dateCreated: Date
    let name: String?
    let members: Array<String>?
 
    
    
    init(
        chatId: String,
        dateCreated: Date? = nil,
        name: String? = nil,
        members: Array<String>? = nil
       
    )
    {
        self.chatId = chatId
        self.dateCreated = Date()
        self.name = name
        self.members = members
       
    }
    
    
}

final class ChatManager{
    
    static let shared = ChatManager()
    private init() { }
    
    //so you dont have to type this many times... creates cleaner code
   
    private let chatCollection = Firestore.firestore().collection("chats")
    
    private func chatDocument(chatId: String) -> DocumentReference {
        chatCollection.document(chatId)
        
    }
    
    func createNewChat(chat: DBChat) async throws {

        try chatDocument(chatId: chat.chatId ).setData(from: chat, merge: false)

    }
    
    
    
    func getChat(chatId: String) async throws -> DBChat {

        try await chatDocument(chatId: chatId).getDocument(as: DBChat.self)
        
    }
    
    
    
}



//
//  NewMessageManager.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//


import Foundation
import FirebaseFirestore

final class MessageManager {
    
    static let shared = MessageManager()
    private init() { }
    

    private let spaceCollection = Firestore.firestore().collection("spaces")
        
    // Get the document reference for a specific space
    private func spaceDocument(spaceId: String) -> DocumentReference {
        spaceCollection.document(spaceId)
    }
    
    // Get the chat collection reference for a specific space
    private func messageCollection(spaceId: String) -> CollectionReference {
        spaceDocument(spaceId: spaceId).collection("chat")
            .document("mainChat")
            .collection("chatlogs")
    }
    
    // Get the document reference for a specific message
    private func messageDocument(messageId: String, spaceId: String) -> DocumentReference {
        messageCollection(spaceId: spaceId)
//            .document("2m6QKW3n2Ezqafh3NvWP")
            .document(messageId)
    }
    
    // Get a query for all messages in a specific space
    func getMessagesQuery(spaceId: String,count: Int) -> Query {
        
        messageCollection(spaceId: spaceId)
            .limit(to: count)
        
        
        
       
            .order(by: "ts", descending: true)
        
    }
    
    
    
    func getThreadQuery(spaceId: String, count: Int, threadId: String) -> Query {
    
        messageCollection(spaceId: spaceId)
        
            .whereField("threadId", isEqualTo: threadId)
            .limit(to: count)
            .order(by: "ts", descending: true)
        
    }
    
    
    
    func getMessage(messageId: String, spaceId: String)  async throws -> Message {
           try await messageDocument(messageId: messageId, spaceId: spaceId).getDocument(as: Message.self)
       }
    
    func getAllMessages(spaceId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Message], lastDocument: DocumentSnapshot?) {
        var query: Query = getMessagesQuery(spaceId: spaceId, count: count)

        
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Message.self)
    }
    
    func getThreadMessages(spaceId: String, count: Int, lastDocument: DocumentSnapshot?, threadId: String) async throws -> (products: [Message], lastDocument: DocumentSnapshot?) {
        var query: Query = getThreadQuery(spaceId: spaceId, count: count, threadId: threadId)

//        
//        print(threadId)
//        print("_____")
//        
        
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Message.self)
    }
    
    
    
}

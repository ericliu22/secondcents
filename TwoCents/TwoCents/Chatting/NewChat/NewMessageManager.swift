//
//  NewMessageManager.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NewMessageManager {
    
    static let shared = NewMessageManager()
    private init() { }
    

    private let spaceCollection = Firestore.firestore().collection("spaces")
        
    // Get the document reference for a specific space
    private func spaceDocument(spaceId: String) -> DocumentReference {
        spaceCollection.document(spaceId)
    }
    
    // Get the chat collection reference for a specific space
    private func messageCollection(spaceId: String) -> CollectionReference {
        spaceDocument(spaceId: spaceId).collection("chat")
    }
    
    // Get the document reference for a specific message
    private func messageDocument(messageId: String, spaceId: String) -> DocumentReference {
        messageCollection(spaceId: spaceId).document(messageId)
    }
    
    // Get a query for all messages in a specific space
    func getAllMessagesQuery(spaceId: String) -> Query {
        
        messageCollection(spaceId: spaceId)
            .document("mainChat")
            .collection("chatlogs")
        
        
        
       
            .order(by: "ts", descending: true)
        
    }
    func getMessage(messageId: String, spaceId: String)  async throws -> Message {
           try await messageDocument(messageId: messageId, spaceId: spaceId).getDocument(as: Message.self)
       }
    
    func getAllMessages(spaceId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Message], lastDocument: DocumentSnapshot?) {
        var query: Query = getAllMessagesQuery(spaceId: spaceId)

        
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Message.self)
    }
    
//    func getProductsByRating(count: Int, lastRating: Double?) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//            .limit(to: count)
//            .start(after: [lastRating ?? 9999999])
//            .getDocuments(as: Product.self)
//    }
//    
//    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Product], lastDocument: DocumentSnapshot?) {
//        if let lastDocument {
//            return try await productsCollection
//                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//                .limit(to: count)
//                .start(afterDocument: lastDocument)
//                .getDocumentsWithSnapshot(as: Product.self)
//        } else {
//            return try await productsCollection
//                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//                .limit(to: count)
//                .getDocumentsWithSnapshot(as: Product.self)
//        }
//    }
//    
//    func getAllProductsCount() async throws -> Int {
//        try await productsCollection
//            .aggregateCount()
//    }
//    
}

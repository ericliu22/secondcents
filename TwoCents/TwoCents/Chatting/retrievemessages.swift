//
//  retrievemessages.swift
//  TwoCents
//
//  Created by Joshua Shen on 9/11/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessageManager: ObservableObject{
    let testchatUser = "Eric"
    let testchatRoom = "ChatRoom1"
    @Published private(set) var messages: [Message] = []
    let db = Firestore.firestore()
    
    init() {
        fetchMessages()
    }
    
    func fetchMessages() {
        db.collection("Chatrooms").document(testchatRoom).collection("Chats").order(by: "ts", descending: false).addSnapshotListener { querySnapshot, error in guard let documents = querySnapshot?.documents else {
            print("message not retrieved")
            return
        }
            self.messages = documents.compactMap { document -> Message? in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("error decoding document into message")
                    return nil
                }
            }
            //self.messages.sort {$0.ts < $1.ts}
        }
    }
    
    func sendMessages(text: String) {
        do {
            let newMessage = Message(id: "\(UUID())", sendBy: testchatUser, text: text, ts: Date())
            try db.collection("Chatrooms").document(testchatRoom).collection("Chats").document().setData(from: newMessage)
            } catch {
            print("Error adding message to Firestore: \(error)")
        }
    }
}
           

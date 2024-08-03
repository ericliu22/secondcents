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

class MessageManager: ObservableObject {
   
//    let testchatRoom = "ChatRoom1"
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""
    @Published private(set) var limitReached: Bool = false
    var fetchCount = 0
    let MESSAGE_LIMIT = 100
    let db = Firestore.firestore()
    
    private var userUID: String
    
    
    private var spaceId: String
  
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        fetchMessages()
        
       
    }
    
    func fetchMessages() {
        db.collection("spaces")
            .document(spaceId)
            .collection("chat")
            .document("mainChat")
            .collection("chatlogs")
            .order(by: "ts", descending: true)
            .limit(to: MESSAGE_LIMIT)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else {
                    return
                }
                guard let documents = querySnapshot?.documents else {
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
                if (self.messages.count < self.MESSAGE_LIMIT) {
                    self.limitReached = true
                }
                self.fetchCount = self.messages.count
                self.messages.sort {$0.ts < $1.ts}
                if let id = self.messages.last?.id{
                    self.lastMessageId = id
                }
        }
    }
    
   
    func fetchMoreMessages() {
        db.collection("spaces")
            .document(spaceId)
            .collection("chat")
            .document("mainChat")
            .collection("chatlogs")
            .order(by: "ts", descending: true)
            .start(after: [messages.first?.ts as Any])
            .limit(to: MESSAGE_LIMIT)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else {
                    print("Reference to self is gone")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("message not retrieved")
                    return
                }
                let newMessages = documents.compactMap { document -> Message? in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print("error decoding document into message")
                        return nil
                    }
                }
                if (newMessages.count < self.MESSAGE_LIMIT) {
                    self.limitReached = true
                }
                let filteredMessages = newMessages.filter({message in
                    message.id != self.messages.first?.id
                })
                self.fetchCount = self.messages.count
                self.messages.append(contentsOf: filteredMessages)
                self.messages.sort {$0.ts < $1.ts}
                if let id = self.messages.last?.id{
                    self.lastMessageId = id
                }
               
        }
    }
   
    func sendMessages(text: String?, widget: CanvasWidget?) {
        let docRef = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")

        docRef.getDocument{ [self] (document, error) in
            if let document = document {
                let property = document.get("lastSend")
                
               
                do {
                    //if there is both text and widget, send widget first seperately, then the text.
                    if text != nil && widget != nil {
                        messageNotification(spaceId: spaceId, userUID: self.userUID, message: (text == "" ? "Replied to a widget" : text)!)
                        sendMessages(text: nil, widget: widget)
                        sendMessages(text: text, widget: nil)
                        
                    } else {
                        let uuidString = UUID().uuidString
                        let mainChatReference = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")
                        let newMessage = Message(id: uuidString, sendBy: userUID, text: text, ts: Date(), parent: (property as? String) ?? "", widgetId: widget?.id.uuidString)
                        try mainChatReference.collection("chatlogs").document(uuidString).setData(from: newMessage)
                        mainChatReference.setData(["lastSend": newMessage.sendBy], merge: true)
                        mainChatReference.setData(["lastTs": newMessage.ts], merge: true)
                        
                       
                    }
                    
                    
                    
                    
                    } catch {
                    print("Error adding message to Firestore: \(error)")
                }
                
            } else {
                print("Document does not exist in cache")
            }
        }
        
    }
    
    
    
    
    
}
           

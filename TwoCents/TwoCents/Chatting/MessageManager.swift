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
    @Published var messageCount: Int = 10
    let db = Firestore.firestore()
    
    private var userUID: String
    
    
    private var spaceId: String
  
    
    init(spaceId: String) {
        print("initialize MessageManager")
        self.spaceId = spaceId
        self.userUID = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        fetchMessages()
        
       
    }
    
    func fetchMessages() {
        print("fetched messages")
        db.collection("spaces")
            .document(spaceId)
            .collection("chat")
            .document("mainChat")
            .collection("chatlogs")
            .order(by: "ts", descending: true)
            .limit(to: 10)
            .addSnapshotListener { querySnapshot, error in
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
                self.messages.sort {$0.ts < $1.ts}
                if let id = self.messages.last?.id{
                    self.lastMessageId = id
                }
        }
    }
    
    //Eric: A function that reads 10 documents after the last document currently read
    //Then adds the 10 messages to MessageManager.messages
    func fetchMoreMessages() {
        print("fetched more messages")
        db.collection("spaces")
            .document(spaceId)
            .collection("chat")
            .document("mainChat")
            .collection("chatlogs")
            .order(by: "ts", descending: true)
            .start(after: [messages.first?.ts as Any])
            .limit(to: 10)
            .addSnapshotListener { querySnapshot, error in
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
                let filteredMessages = newMessages.filter({message in
                    message.id != self.messages.first?.id
                })
                self.messages.append(contentsOf: filteredMessages)
                self.messages.sort {$0.ts < $1.ts}
                if let id = self.messages.last?.id{
                    self.lastMessageId = id
                }
                //Eric: is able to print out 20 which is in fact 10 more than the initla message count of 10
                print("new fetch count:\(self.messages.count)")
              
               
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
                        sendMessages(text: nil, widget: widget)
                        sendMessages(text: text, widget: nil)
                        
                    } else {
                        let mainChatReference = db.collection("spaces").document(spaceId).collection("chat").document("mainChat")
                        let newMessage = Message(id: "\(UUID())", sendBy: userUID, text: text, ts: Date(), parent: (property as? String) ?? "", widgetId: widget?.id.uuidString)
                        try mainChatReference.collection("chatlogs").document().setData(from: newMessage)
                        mainChatReference.setData(["lastSend": newMessage.sendBy], merge: true)
                        mainChatReference.setData(["lastTs": newMessage.ts], merge: true)
                        
                        messageNotification(spaceId: spaceId, userUID: self.userUID, message: text!)
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
           

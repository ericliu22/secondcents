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
   
//    let testchatRoom = "ChatRoom1"
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""
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
            .order(by: "ts", descending: false)
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
            //self.messages.sort {$0.ts < $1.ts}
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
                        sendMessages(text: nil, widget: widget)
                        sendMessages(text: text, widget: nil)
                 
                     
                        
                        
                    } else {
                        
                        let newMessage = Message(id: "\(UUID())", sendBy: userUID, text: text, ts: Date(), parent: (property as? String) ?? "", widgetId: widget?.id.uuidString)
                        try self.db.collection("spaces").document(spaceId).collection("chat").document("mainChat").collection("chatlogs").document().setData(from: newMessage)
                        self.db.collection("spaces").document(spaceId).collection("chat").document("mainChat").setData(["lastSend": newMessage.sendBy], merge: true)
                        db.collection("spaces").document(spaceId).collection("chat").document("mainChat").setData(["lastTs": newMessage.ts], merge: true)
                        
                        let firstNotification = Notification(title: "HELLO FROM ERIC", body: "FIRST NOTIFICATION");
                        sendSingleNotification(to: "coc5utRXp00vkWGM7met4r:APA91bFyMUyzKCQu2c45Pm-hqWE_eppgoDIqiIIkIwLGVOy2rUORVmtwBNDpQaD8LX1T9YtSeNmBJlKIsp4iL5jwvrPF9XEKCKtu9U4PmF7dpdkr8C3kvlBtRkqzqG8wPOYb7CBhC1aa", notification: firstNotification) { completion in
                                
                            if (completion) {
                                
                                print("SUCCEDED")
                            
                            }
                        }
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
           

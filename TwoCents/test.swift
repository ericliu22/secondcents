//
//  test.swift
//  TwoCents
//
//  Created by Joshua Shen on 11/10/23.
//

import Foundation
//func sendMessages(text: String) {
//    let docRef = db.collection("Chatrooms").document(testchatRoom)
//
//    docRef.getDocument(source: .cache) { [self] (document, error) in
//        if let document = document {
//            let property = document.get("lastSend")
//            print(property) //<-- how to access globally?
//            do {
//                let newMessage = Message(id: "\(UUID())", sendBy: self.testchatUser, text: text, ts: Date(), parent: property as! String)
//                try self.db.collection("Chatrooms").document(self.testchatRoom).collection("Chats").document().setData(from: newMessage)
//                self.db.collection("Chatrooms").document(self.testchatRoom).setData(["lastSend": newMessage.sendBy], merge: true)
//                db.collection("Chatrooms").document(self.testchatRoom).setData(["lastTs": newMessage.ts], merge: true)
//                } catch {
//                print("Error adding message to Firestore: \(error)")
//            }
//            
//        } else {
//            print("Document does not exist in cache")
//        }
//    }
//    
//}

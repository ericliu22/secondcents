//
//  ReactionFunctions.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/4/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

//class ReactionManager: ObservableObject{
//    let testchatUser = "Josh"
//    let testchatRoom = "ChatRoom1"
//    @Published private(set) var emoji: [Emoji] = []
//    @Published private(set) var testingWidgetID = ""
//    let db = Firestore.firestore()
//    
////    init() {
////        writeEmojiToFirebase()
////    }
//    
//    func writeEmojiToFirebase(emoji: String) {
//        let docRef = db.collection("Chatrooms").document(testchatRoom)
//        
//        docRef.getDocument{ [self] (document, error) in
//            //not if let document = document?
//            if document != nil{
//                do{
//                    let newEmoji = Emoji(sendBy: self.testchatUser, emoji: emoji)
//                    let emojiMap = ()
//                    try
//                    self.db.collection("Chatrooms").document(testchatRoom).collection("Chats").document("emojitest").updateData("reactions" [newEmoji.sendBy,: newEmoji.emoji])/*.setData([newEmoji.sendBy: newEmoji.emoji], merge: true)*/
//                } catch {
//                    print("Error adding emoji to Firestore: \(error)")
//                }
//            }
//        }
//    }
//}

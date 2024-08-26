//
//  Unread.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/12.
//

import Foundation
import Firebase

/*
 Unread types:
 
 Unread widget
    -Badge that says new in the color of the user that posted the widget
    -Maybe new for edits to widget
 Unread message
    -Show as a line "New messages below"
    -Maybe add timestamps for messages that are far apart?
    -Scroll to new messages
 
 User:
    Count: Number of unreads
    Widgets: [String] of the UUIDs of the widgets
    Messages: A cursor to the last message seen
 */


func addMessageUnread(spaceId: String, userId: String) {
    print("ADDDING MESSAGE UNREAD")
    Firestore.firestore().collection("spaces").document(spaceId).collection("unreads").document(userId).setData([
        "count": FieldValue.increment(Double(1))
    ], merge: true)
}

func addWidgetUnread(spaceId: String, userId: String, widgetId: String) {
    DispatchQueue.global().async {
        db.collection("spaces").document(spaceId).collection("unreads").document(userId).setData([
            "widgets": FieldValue.arrayUnion([widgetId]),
            "count": FieldValue.increment(Double(1))
        ], merge: true)
    }
}

fileprivate func fetchLatestMessage(spaceId: String) async -> String? {
    guard let first = try? await db.collection("spaces")
        .document(spaceId)
        .collection("chat")
        .document("mainChat")
        .collection("chatlogs")
        .order(by: "ts", descending: true)
        .limit(to: 1)
        .getDocuments()
        .documents
        .first
    else {
        print("Unreads: failed to retrieve latest message")
        return nil
    }
    
    return first.documentID
}

func widgetUnread(spaceId: String, widgetId: String) async {
    guard let space = try? await spaceCollection.document(spaceId).getDocument(as: DBSpace.self) else {
        print("Unreads: failed to get space")
        return
    }
    guard let members = space.members else {
        print("This should never happen")
        return
    }
    for memberId in members {
        addWidgetUnread(spaceId: spaceId, userId: memberId, widgetId: widgetId)
    }
}
 

func messageUnread(spaceId: String) async {
    guard let space = try? await spaceCollection.document(spaceId).getDocument(as: DBSpace.self) else {
        print("Unreads: failed to get space")
        return
    }
    guard let members = space.members else {
        print("This should never happen")
        return
    }
    print(members)
    for memberId in members {
        addMessageUnread(spaceId: spaceId, userId: memberId)
    }
}

func readNotifications (spaceId: String) async {
    guard let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
        print("Unreads: failed to get authenticated user")
        return
    }
    
    //This is dogshit but should change to more efficient thing
    guard let messageId = await fetchLatestMessage(spaceId: spaceId) else {
        print("Unreads: failed to get message id from helper function")
        return
    }
    
    do {
        try await db.collection("spaces").document(spaceId).collection("unreads").document(userId).setData([
            "count": 0,
            "widgets": [],
            "message": messageId
        ], merge: true)
    } catch {
        print("Unreads: failed to update notification")
    }
}

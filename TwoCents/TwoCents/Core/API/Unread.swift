//
//  Unread.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/12.
//

import Foundation
import FirebaseFirestore

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
    spaceReference(spaceId: spaceId).collection("unreads").document(userId).setData([
        "count": FieldValue.increment(Double(1))
    ], merge: true)
}

func addWidgetUnread(spaceId: String, userId: String, widgetId: String) {
    DispatchQueue.global().async {
        spaceReference(spaceId: spaceId)
        .collection("unreads").document(userId).setData([
            "widgets": FieldValue.arrayUnion([widgetId]),
            "count": FieldValue.increment(Double(1))
        ], merge: true)
    }
}

fileprivate func fetchLatestMessage(spaceId: String) async -> String? {
    guard let first = try? await spaceReference(spaceId: spaceId)
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

func widgetUnread(spaceId: String, widgetId: String, userId: String) async {
    guard let space = try? await spaceCollection.document(spaceId).getDocument(as: DBSpace.self) else {
        print("Unreads: failed to get space")
        return
    }
    guard let members = space.members else {
        print("This should never happen")
        return
    }
    for memberId in members {
        if userId == memberId {
            continue
        }
        addWidgetUnread(spaceId: spaceId, userId: memberId, widgetId: widgetId)
    }
}

func getUnreadWidgets(spaceId: String, userId: String) async -> [String]? {
    return try? await spaceReference(spaceId: spaceId)
        .collection("unreads")
        .document(userId)
        .getDocument()
        .data()?["widgets"] as? [String]
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

func readNotifications (spaceId: String, userId: String) async {
    //This is dogshit but should change to more efficient thing
    guard let messageId = await fetchLatestMessage(spaceId: spaceId) else {
        print("Unreads: failed to get message id from helper function")
        return
    }
    
    do {
        try await spaceReference(spaceId: spaceId).collection("unreads").document(userId).setData([
            "count": 0,
            "widgets": [],
            "message": messageId
        ], merge: true)
    } catch {
        print("Unreads: failed to update notification")
    }
}

func readWidgetUnread(spaceId: String, userId: String, widgetId: String) async {
    do {
        try await spaceReference(
            spaceId: spaceId
        )
        .collection("unreads")
        .document(userId)
        .updateData([
            "widgets":
                FieldValue.arrayRemove([
                    widgetId
                ]),
            "count": FieldValue.increment(
                Int64(-1)),
        ])
    } catch {
        print("Failed to read widget unreaad")
    }
}

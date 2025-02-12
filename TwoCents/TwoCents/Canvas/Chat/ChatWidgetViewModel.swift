import FirebaseFirestore
//
//  ChatWidgetViewModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/15.
//
import SwiftUI

@Observable @MainActor
class ChatWidgetViewModel {
    let spaceId: String
    let chatId: String
    var messageType: MessageType = .text
    var chat: Chat?
    var message: String = ""
    var changeIndices: [Int] = []
    var lastDocument: DocumentSnapshot?
    private let chatRef: DocumentReference
    private let FETCH_LIMIT: Int = 20
    @ObservationIgnored private var messageListener: ListenerRegistration?

    var messages: [any Message] = []

    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
        chatRef = spaceReference(spaceId: spaceId)
.collection("chats").document(chatId)
        attachMessageListener()
        Task {
            await fetchChat()
        }
    }

    func fetchChat() async {
        guard let chatDoc = try? await chatRef.getDocument(as: Chat.self) else {
            return
        }
        chat = chatDoc
    }
    
    deinit {
        messageListener?.remove()
    }

    func attachMessageListener() {
        let messagesRef = chatRef.collection("messages")

        // Order by timestamp descending, limited to last 20
        messageListener = messagesRef
            .order(by: "dateCreated", descending: true)
            .limit(to: FETCH_LIMIT)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for updates: \(error)")
                    return
                }

                guard let snapshot = querySnapshot else { return }
                // Convert snapshot documents to Message objects
                self.messages = snapshot.documents.compactMap {
                    doc -> (any Message)? in

                    guard
                        let messageTypeString = doc.data()["messageType"]
                            as? String
                    else {
                        print("Failed to convert type")
                        return EmptyMessage()
                    }
                    guard
                        let messageType = MessageType(
                            rawValue: messageTypeString)
                    else {
                        print("Failed to convert type")
                        return EmptyMessage()
                    }

                    switch messageType {
                    case .text:
                        guard let message = try? doc.data(as: TextMessage.self)
                        else {
                            return EmptyMessage()
                        }
                        return message
                    default:
                        guard let message = try? doc.data(as: EmptyMessage.self)
                        else {
                            return EmptyMessage()
                        }
                        return message
                    }
                }
                guard let doc = snapshot.documents.last else { return }
                self.lastDocument = doc
                messageSenderChangeIndices()
            }
    }

    func fetchOlderMessages() {
        let messagesRef = chatRef.collection("messages")

        guard let lastDocument = lastDocument else { return }

        messagesRef
            .order(by: "dateCreated", descending: true)
            .start(afterDocument: lastDocument)  // We'll get older messages than the last doc in the current batch
            .limit(to: FETCH_LIMIT)
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching older messages: \(error)")
                    return
                }

                guard let snapshot = querySnapshot else {
                    return
                }
                let empty = EmptyMessage()

                let messages: [any Message] = snapshot.documents
                    .compactMap { doc in

                        guard
                            let messageTypeString = doc.data()["messageType"]
                                as? String
                        else { return empty }

                        switch messageTypeString {
                        case "text":
                            guard
                                let message = try? doc.data(
                                    as: TextMessage.self)
                            else {
                                return empty
                            }
                            return message
                        default:
                            guard
                                let message = try? doc.data(
                                    as: EmptyMessage.self)
                            else {
                                return empty
                            }
                            return message
                        }
                    }

                self.messages.insert(contentsOf: messages, at: 0)

                guard let doc = snapshot.documents.last else { return }
                // The last document in this query is the new "oldest" message
                self.lastDocument = doc
                messageSenderChangeIndices()
            }
    }
    
    
    func messageSenderChangeIndices() {
        // If we have no messages, return an empty array
        guard !messages.isEmpty else { return }
        
        // The first message is always a "change" since there's nothing before it
        changeIndices = [messages.count-1]
        
        for i in 0..<messages.count-1 {
            // Check if this message is from a different sender than the previous one
            if messages[i].sendBy != messages[i + 1].sendBy {
                changeIndices.append(i)
            }
        }
    }
    
    func messageChange(messageId: String) -> Bool {
        guard let index = messages.firstIndex(where: { $0.id == messageId}) else {
            return false
        }
        return changeIndices.contains([index])
    }
    

    func sendMessage(userId: String) {

        var finalMessage: any Message
        switch messageType {
        case .text:
            finalMessage = TextMessage(
                sendBy: userId, text: message)
        default:
            finalMessage = EmptyMessage()
        }

        do {
            try chatRef.collection("messages").document(finalMessage.id)
                .setData(from: finalMessage)
            print(finalMessage)
        } catch {
            print("Failed to send message")
        }
        let tempMessage = message
        message = ""
        Task {
            try await chatWidgetNotification(spaceId: spaceId, body: tempMessage, widgetId: chatId)
            await widgetUnread(spaceId: spaceId, widgetId: chatId, userId: userId)
        }
    }

}

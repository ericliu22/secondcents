import SwiftUI
import FirebaseFirestore

@MainActor
final class NewChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var threadMessages: [Message] = []
  
    @Published private(set) var messagesFromListener: [Message] = []
    private var lastDocument: DocumentSnapshot? = nil
    @Published var hasMoreMessages: Bool = true

    func getOldMessages(spaceId: String, completion: ((Bool, String?) -> Void)? = nil) {
        Task {
            do {
                let (newMessages, lastDocument) = try await NewMessageManager.shared.getAllMessages(spaceId: spaceId, count: 20, lastDocument: self.lastDocument)
                
                if newMessages.isEmpty {
                    self.hasMoreMessages = false
                } else {
                    self.hasMoreMessages = true
                    let existingMessageIDs = Set(self.messages.map { $0.id })
                    let uniqueMessages = newMessages.filter { !existingMessageIDs.contains($0.id) }
                    self.messages.append(contentsOf: uniqueMessages)
                    if let lastDocument = lastDocument {
                        self.lastDocument = lastDocument
                    }
                }
                
                completion?(false, nil)
            } catch {
                print("Failed to fetch old messages: \(error)")
            }
        }
    }
    
    func getThreadMessages(spaceId: String, threadId: String, completion: ((Bool, String?) -> Void)? = nil) {
        Task {
            do {
                let (newMessages, lastDocument) = try await NewMessageManager.shared.getThreadMessages(spaceId: spaceId, count: 20, lastDocument: self.lastDocument, threadId: threadId)
                
                
                print(newMessages)
                if newMessages.isEmpty {
                    self.hasMoreMessages = false
                } else {
                    self.hasMoreMessages = true
                    let existingMessageIDs = Set(self.threadMessages.map { $0.id })
                    let uniqueMessages = newMessages.filter { !existingMessageIDs.contains($0.id) }
                    self.threadMessages.append(contentsOf: uniqueMessages)
                    if let lastDocument = lastDocument {
                        self.lastDocument = lastDocument
                    }
                }
                
                
//                print("got thread msgs")
//                print(threadMessages)
                completion?(false, nil)
            } catch {
                print("Failed to fetch thread messages: \(error)")
            }
        }
    }
    
    func fetchNewMessages(spaceId: String) {
        let currentTime = Date()
        
        db.collection("spaces")
            .document(spaceId)
            .collection("chat")
            .document("mainChat")
            .collection("chatlogs")
            .order(by: "ts", descending: true)
            .whereField("ts", isGreaterThan: currentTime)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Failed to retrieve messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messagesFromListener = documents.compactMap { document -> Message? in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print("Error decoding document into message: \(error)")
                        return nil
                    }
                }
            }
    }
}

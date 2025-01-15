import SwiftUI
import FirebaseFirestore

@Observable @MainActor
final class ChatViewModel {
    var messages: [Message] = []
    var hasMoreMessages: Bool = true
    var messagesFromListener: [Message] = []
    private var lastDocument: DocumentSnapshot? = nil
    var threadId: String = ""
    var threadIdChangedTime: Date = Date()
    var isLoading: Bool = false
    let spaceId: String
    
    init(spaceId: String ) {
        self.spaceId = spaceId
    }
    
    
//    @Published private(set) var user:  DBUser? = nil
//    func loadCurrentUser() async throws {
//        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
//    }
    

    func getOldMessages(spaceId: String, completion: ((Bool, String?) -> Void)? = nil) {
        Task {
            do {
                let (newMessages, lastDocument) = try await MessageManager.shared.getAllMessages(spaceId: spaceId, count: 20, lastDocument: self.lastDocument)
           
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
    
    
    
    func removeMessages() {
        
        self.messages.removeAll()
        self.messagesFromListener.removeAll()
        self.lastDocument = nil
    }
    
    func getThreadMessages(spaceId: String, threadId: String, completion: ((Bool) -> Void)? = nil) {
        
        Task {
            
            do {
                let (newMessages, lastDocument) = try await MessageManager.shared.getThreadMessages(spaceId: spaceId, count: 20, lastDocument: self.lastDocument, threadId: threadId)
                
                for message in newMessages {
                    if let threadId = message.threadId {
                        print(threadId)
                    }
                }

                
                if newMessages.isEmpty {
                    self.hasMoreMessages = false
                } else {
                    self.hasMoreMessages = true
                    let existingMessageIds = Set(self.messages.map { $0.id })
                    let existingMessagesFromListenerIds = Set(self.messagesFromListener.map { $0.id })
                    
                    let allExistingIds = existingMessageIds.union(existingMessagesFromListenerIds)
                            
                    let uniqueMessages = newMessages.filter { !allExistingIds.contains($0.id) }
                
                    self.messages.append(contentsOf: uniqueMessages)
                    if let lastDocument = lastDocument {
                        self.lastDocument = lastDocument
                    }
                }
                
                
                
                completion?(true)
                
            } catch {
                print("Failed to fetch old messages: \(error)")
            }
            
       
        }
       
    }
    
    
    
    
}

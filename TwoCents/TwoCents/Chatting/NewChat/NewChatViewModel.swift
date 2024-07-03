
import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
final class NewChatViewModel: ObservableObject {
    
    @Published private(set) var messages: [Message] = []
//    @Published var selectedFilter: FilterOption? = nil
//    @Published var selectedCategory: CategoryOption? = nil
    private var lastDocument: DocumentSnapshot? = nil

    
    @Published var hasMoreMessages: Bool = true
    
    
    func getMessages(spaceId: String, completion: ((Bool, String?) -> Void)? = nil){
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
                    
//                    print(newMessages)
                } catch {
                    print("Failed to fetch messages: \(error)")
                }
            }
        }

}

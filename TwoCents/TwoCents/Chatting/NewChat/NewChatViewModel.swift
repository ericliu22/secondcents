
import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
final class NewChatViewModel: ObservableObject {
    
    @Published private(set) var messages: [Message] = []
//    @Published var selectedFilter: FilterOption? = nil
//    @Published var selectedCategory: CategoryOption? = nil
    private var lastDocument: DocumentSnapshot? = nil

//    enum FilterOption: String, CaseIterable {
//        case noFilter
//        case priceHigh
//        case priceLow
//        
//        var priceDescending: Bool? {
//            switch self {
//            case .noFilter: return nil
//            case .priceHigh: return true
//            case .priceLow: return false
//            }
//        }
//    }
//    
//    func filterSelected(option: FilterOption) async throws {
//        self.selectedFilter = option
//        self.products = []
//        self.lastDocument = nil
//        self.getProducts()
//    }
//    
//    enum CategoryOption: String, CaseIterable {
//        case noCategory
//        case smartphones
//        case laptops
//        case fragrances
//        
//        var categoryKey: String? {
//            if self == .noCategory {
//                return nil
//            }
//            return self.rawValue
//        }
//    }
//    
//    func categorySelected(option: CategoryOption) async throws {
//        self.selectedCategory = option
//        self.products = []
//        self.lastDocument = nil
//        self.getProducts()
//    }
//    
    func getMessages(spaceId: String) {
        Task {
            do {
                let (newMessages, lastDocument) = try await NewMessageManager.shared.getAllMessages(spaceId: spaceId, count: 2, lastDocument: self.lastDocument)
                
                // Create a set of existing message IDs for faster lookup
                let existingMessageIDs = Set(self.messages.map { $0.id })
                
                // Filter out new messages that are already present
                let uniqueMessages = newMessages.filter { !existingMessageIDs.contains($0.id) }
                
                // Append unique messages to the messages array
                self.messages.append(contentsOf: uniqueMessages)
                
                // Update lastDocument if not nil
                if let lastDocument = lastDocument {
                    self.lastDocument = lastDocument
                }
            } catch {
                print("Failed to fetch messages: \(error)")
            }
        }
    }
//    func addUserFavoriteProduct(productId: Int) {
//        Task {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            try? await UserManager.shared.addUserFavoriteProduct(userId: authDataResult.uid, productId: productId)
//        }
//    }
    
//    func getProductsCount() {
//        Task {
//            let count = try await ProductsManager.shared.getAllProductsCount()
//            print("ALL PRODUCT COUNT: \(count)")
//        }
//    }
    
//    func getProductsByRating() {
//        Task {
////            let newProducts = try await ProductsManager.shared.getProductsByRating(count: 3, lastRating: self.products.last?.rating)
//
//            let (newProducts, lastDocument) = try await ProductsManager.shared.getProductsByRating(count: 3, lastDocument: lastDocument)
//            self.products.append(contentsOf: newProducts)
//            self.lastDocument = lastDocument
//        }
//    }
}

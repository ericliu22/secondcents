//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI


@Observable @MainActor
final class SpacesViewModel {
    
    var user:  DBUser? = nil
    var allSpaces: [DBSpace] = []
    var finishedLoading: Bool = false
    var notificationCount: [String: Int] = [:]
    var presentedPath: [DBSpace] = []
    var newSpaceUUID = UUID().uuidString
    var searchTerm = ""
    var isShowingCreateSpaces: Bool = false
    
    init() {
        Task {
            try? await loadCurrentUser()
            guard let user = user else {
                print("SpacesViewModel: Failed to get current user")
                return
            }
            attachSpacesListener(userId: user.userId)
            await getNotifcationCount()
        }
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
//    func getAllSpaces(userId: String) async throws {
//        try? await loadCurrentUser()
//        
//        self.allSpaces = try await UserManager.shared.getAllSpaces(userId: userId)
//        
//        finishedLoading = true
//        
//    }
    
    func attachSpacesListener(userId: String) {
        Firestore.firestore().collection("spaces").whereField("members", arrayContains: userId).addSnapshotListener({ [weak self] querySnapshot, error in
            guard let self = self else {
                print("SpacesViewModel: attachSpacesLitener weak self no reference")
                return
            }
            
            guard let query = querySnapshot else {
                print("Error fetching query: \(error)")
                return
            }
            
            self.allSpaces = []
            for document in query.documents {
                let space = try! document.data(as: DBSpace.self)
                self.allSpaces.append(space)
            }
            self.finishedLoading = true
        })
    }
    
    func getNotifcationCount() async {
        guard let user = user else {
            print("SpacesViewModel: no user")
            return
        }
        for space in allSpaces {
            guard let unreadCount = try? await db.collection("spaces")
                .document(space.id)
                .collection("unreads")
                .document(user.id)
                .getDocument()
                .data()?["count"] as? Int else {
                continue
            }
            notificationCount[space.id] = unreadCount
        }
    }
    
    
}

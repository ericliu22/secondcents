//
//  SearchUserViewModel.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI


@Observable
final class SpacesViewModel {
    
    var user:  DBUser? = nil
    var allSpaces: [DBSpace] = []
    var finishedLoading: Bool = false
    var notificationCount: [String: Int] = [:]
    
    init() {
        Task {
            try? await loadCurrentUser()
            guard let user = user else {
                print("SpacesViewModel: Failed to get current user")
                return
            }
            try? await getAllSpaces(userId: user.userId)
            await getNotifcationCount()
        }
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func getAllSpaces(userId: String) async throws {
        try? await loadCurrentUser()

        self.allSpaces = try await UserManager.shared.getAllSpaces(userId: userId)
        
        finishedLoading = true

    }
    
    func getUserColor(userColor: String) -> Color{

        return Color.fromString(name: userColor)
        
    }
    
    func getNotifcationCount() async {
        guard let user = user else {
            print("SpacesViewModel: no user")
            return
        }
        for space in allSpaces {
            db.collection("spaces").document(space.id).collection("unreads").document(user.id).addSnapshotListener({ [weak self] snapshot, error in
                
                guard let self = self else { return }
                guard let snapshot = snapshot else { return}
                guard let count = snapshot.data()?["count"] as? Int else {
                    return
                }
                self.notificationCount[space.id] = count
            })
        }
    }
    
}

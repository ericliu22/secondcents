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
            //await getNotifcationCount()
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
        for space in allSpaces {
            guard let unreads = try? await db.collection("spaces").document(space.id).collection("unreads") as? Int else {
                print("Unable to retrive notification count")
                continue
            }
            notificationCount[space.id] = unreads
        }
    }
    
}

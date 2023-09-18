//
//  CanvasPageModel.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/9/8.
//

import Foundation

class CanvasPageModel: ObservableObject {
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
}

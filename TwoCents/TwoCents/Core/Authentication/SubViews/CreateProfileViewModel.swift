//
//  CreateProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class CreateProfileEmailViewModel: ObservableObject{
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
    
    func saveProfileImage(item: PhotosPickerItem) {

        guard let user else { return }
   
        
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
      
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print ("Saved Image")
            print (path)
            print (name)
            let url = try await StorageManager.shared.getURLForImage(path: path)
            try await UserManager.shared.updateUserProfileImage(userId: user.userId, path: path, url: url.absoluteString)
            
            
        }
    }
}

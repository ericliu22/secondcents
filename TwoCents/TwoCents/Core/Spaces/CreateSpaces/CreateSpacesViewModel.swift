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
final class CreateSpacesViewModel: ObservableObject{
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
    
      
      func createSpace() async throws {
//          guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !username.isEmpty, !confirmPassword.isEmpty else {
//              print("Fields are empty")
//              throw URLError(.badServerResponse)
//          }
//          
//          guard password == confirmPassword else {
//              print("password and confirm password are not equal")
//              throw URLError(.badServerResponse)
//
//          }
//          
          
 
          
          let space = DBSpace(spaceId: UUID().uuidString)
          

          
          try await SpaceManager.shared.createNewSpace(space: space)
        
          
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
            print(url)
            try await UserManager.shared.updateUserProfileImage(userId: user.userId, url: url.absoluteString, path: path)
            try? await loadCurrentUser()
            
        }
        
    }
}

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
    
    
    @Published var name = ""

    
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
    
      
    func createSpace(spaceId: String) async throws {
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
          
 
          
        let space = DBSpace(spaceId: spaceId, name: name.isEmpty ? "Untitled Space" : name)
          

          
          try await SpaceManager.shared.createNewSpace(space: space)
        
          
      }
    
    
    
    
    
    func saveProfileImage(item: PhotosPickerItem, spaceId: String) {
       
        guard let space else { return }
        print("here2")
        
        Task {
            print("here1")
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            
            print("here")
         
            let (path, name) = try await StorageManager.shared.saveSpaceProfilePic(data: data, spaceId: space.spaceId)
            print ("Saved Image")
            print (path)
            print (name)
            let url = try await StorageManager.shared.getURLForImage(path: path)
            print(url)
            try await SpaceManager.shared.updateSpaceProfileImage(spaceId: space.spaceId, url: url.absoluteString, path: path)
            try? await loadCurrentSpace(spaceId: spaceId)
            
        }
        
    }
    
    
    @Published private(set) var allFriends: [DBUser] = []
    
    
    func getAllFriends() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.allFriends = try await UserManager.shared.getAllFriends(userId: authDataResult.uid)
    }
    
    func getUserColor(userColor: String) -> Color{

        switch userColor {
            
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }
        
        
        
    }
    
    
    
    
}

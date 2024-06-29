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
    
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func deleteSpace(spaceId: String) async throws {

        
          
          try await SpaceManager.shared.deleteSpace(spaceId: spaceId)
        
          
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

        print("Selected members: \(selectedMembersUserId)")
        if let user = user {
            if !selectedMembersUserId.contains(user.userId){
                selectedMembersUserId.append(user.userId)
            }
            
        }
        let space = DBSpace(spaceId: spaceId, name: name.isEmpty ? "Untitled Space" : name, members: selectedMembersUserId)
          

          
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
    
    
    
    
    @Published private(set) var selectedMembers: [DBUser] = []
    @Published private(set) var selectedMembersUserId: [String] = []
    
    
    func addMember(friend: DBUser) {
        
        // Check if the user is already in the selected members array
        if !selectedMembers.contains(where: { $0.userId == friend.userId }) {
            // Remove user from all friends array
            allFriends.removeAll { user in
                return user.userId == friend.userId
            }
            
            // Add user to selected member array
            selectedMembers.append(friend)
            
            // Add user to selected member UserID array
            selectedMembersUserId.append(friend.userId)
        }
    }

    func removeMember(friend: DBUser) {
        
        // Check if the user is already in the selected members array
        if selectedMembers.contains(where: { $0.userId == friend.userId }) {
            // Remove user from members array
            selectedMembers.removeAll { user in
                return user.userId == friend.userId
            }
            
            // Remove user from members UID array
            selectedMembersUserId.removeAll { user in
                return user == friend.userId
            }
            
            // Add user to all friends array
            allFriends.append(friend)
        }
    }

    
    
    
    func getUserColor(userColor: String) -> Color{

        return Color.fromString(name: userColor)
        
    }
    
    
    
    
}

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


        print(selectedMembersUserId)
        if let user = user {
            
            selectedMembersUserId.append(user.userId)
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
        
        //remove user from all friends array
        allFriends.removeAll { user in
            return user.userId == friend.userId
        }
        
        
        //add user to selected member array
        selectedMembers.append(friend)
        
        //add user to selected member UserID array
        selectedMembersUserId.append(friend.userId)
        
        
    }
    
    func removeMember(friend: DBUser) {
        
        //remove user from members array
        selectedMembers.removeAll { user in
            return user.userId == friend.userId
        }
        
        //remove user from members UID array
        selectedMembersUserId.removeAll { user in
            return user == friend.userId
        }
        
        
        
        //add user to selected member array
        allFriends.append(friend)
        
        
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

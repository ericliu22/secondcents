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
final class SpaceProfilePicViewModel: ObservableObject{
    
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
    
    func saveProfileImage(item: PhotosPickerItem) {
      
    
        guard let space else { return }
        
        
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            
            let (path, name) = try await StorageManager.shared.saveSpaceProfilePic(data: data, spaceId: space.spaceId)
            print ("Saved Image")
            print (path)
            print (name)
            let url = try await StorageManager.shared.getURLForImage(path: path)
            print(url)
            try await SpaceManager.shared.updateSpaceProfileImage(spaceId: space.spaceId, url: url.absoluteString, path: path)
            try? await loadCurrentSpace(spaceId: space.spaceId)
            
        }
        
    }
}

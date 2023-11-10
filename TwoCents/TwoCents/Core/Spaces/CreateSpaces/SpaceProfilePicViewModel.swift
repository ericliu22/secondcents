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
            if let image = UIImage(data: data), let imageData = resizeImage(image: image, targetSize: CGSize(width: 200, height: 200))?.jpegData(compressionQuality: 1)  {
                
                
                let (path, name) = try await StorageManager.shared.saveSpaceProfilePic(data: imageData, spaceId: space.spaceId)
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
    
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio < heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            print( "width")
            print( size.width * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            
            print( "width")
            print( size.width * widthRatio)
        }
        
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

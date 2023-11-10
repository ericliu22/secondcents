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
final class CustomizeProfileViewModel: ObservableObject{
    
    @Published private(set) var user:  DBUser? = nil
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
    
    func saveProfileImage(item: PhotosPickerItem) {
    
        guard let user else { return }
        
        
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            
            if let image = UIImage(data: data), let imageData = resizeImage(image: image, targetSize: CGSize(width: 200, height: 200))?.jpegData(compressionQuality: 1)  {
                
                
                let (path, name) = try await StorageManager.shared.saveProfilePic(data: imageData, userId: user.userId)
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

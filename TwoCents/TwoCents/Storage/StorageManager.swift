//
//  StorageManager.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager{
    //singleton. only creates one instance of the class, and lets it be shared among other files
    static let shared = StorageManager()
    
    private init() {  }
    
    
    private let storage = Storage.storage().reference()
    
    
    private var imageReference: StorageReference {
        storage.child("images")
    }
    
    
    private func userReference(userId: String) -> StorageReference{
        storage.child("users").child(userId)
    }
    
    
    
    func saveImage(data: Data, userId: String)async throws -> (path: String, name: String){
        
        
        let meta = StorageMetadata()
        
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        
        return (returnedPath, returnedName)
        
        
    }
    
    
    func saveImage(image: UIImage, userId: String)async throws -> (path: String, name: String){
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.badURL)
        }
        return try await saveImage(data: data, userId: userId)
    }
    
    
    func getData(userId: String, path: String) async throws -> Data {
//        try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
       return image
    }
    
    func getURLForImage(path: String) async throws  -> URL{
        
        try await Storage.storage().reference(withPath: path).downloadURL()
        
        
    }
    
        
}

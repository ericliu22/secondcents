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
    
    private func spaceReference(spaceId: String) -> StorageReference{
        storage.child("spaces").child(spaceId)
    }
    
    private func imageWidgetReference(spaceId: String) -> StorageReference{
        storage.child("spaces").child(spaceId).child("imageWidgets")
    }
    
    
    
    func saveProfilePic(data: Data, userId: String)async throws -> (path: String, name: String){
        
        
        let meta = StorageMetadata()
        
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        
        return (returnedPath, returnedName)
        
        
    }
    
    
    func saveProfilePic(image: UIImage, userId: String)async throws -> (path: String, name: String){
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.badURL)
        }
        return try await saveProfilePic(data: data, userId: userId)
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
        
        try await  Storage.storage().reference(withPath: path).downloadURL()
        
        
    }
    
    //for spaces
    
    func saveSpaceProfilePic(data: Data, spaceId: String)async throws -> (path: String, name: String){
        
        
        let meta = StorageMetadata()
        
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await spaceReference(spaceId: spaceId).child(path).putDataAsync(data, metadata: meta)
        
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        
        return (returnedPath, returnedName)
        
        
    }
    
    
    func saveSpaceProfilePic(image: UIImage, spaceId: String)async throws -> (path: String, name: String){
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.badURL)
        }
        return try await saveSpaceProfilePic(data: data, spaceId: spaceId)
    }
    
    
    //for widgets
    
    func saveTempWidgetPic(data: Data, spaceId: String, widgetId: String)async throws -> ( path: String, name: String){
        
        
        let meta = StorageMetadata()
        
        meta.contentType = "image/jpeg"
        
//        let widgetId = UUID().uuidString
        let path = "\(widgetId).jpeg"
        let returnedMetaData = try await imageWidgetReference(spaceId: spaceId).child(path).putDataAsync(data, metadata: meta)
        
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        
        return (returnedPath, returnedName)
        
        
    }
    
    
    func saveTempWidgetPic(image: UIImage, spaceId: String, widgetId: String)async throws -> (path: String, name: String){
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.badURL)
        }
        return try await saveTempWidgetPic(data: data, spaceId: spaceId, widgetId: widgetId)
    }
    
    
    func deleteTempWidgetPic(spaceId: String, widgetId: String) async throws {
        
        print("deleted")
  

        let path = "\(widgetId).jpeg"
        
        print(path)
        try await imageWidgetReference(spaceId: spaceId).child(path).delete { error in
            print(error)
            print("NOT WORKING")
        }
        
        
    }
    
}

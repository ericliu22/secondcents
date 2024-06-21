//
//  CreateProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation


@MainActor
final class NewWidgetViewModel: ObservableObject{
    
    
    
    
    
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
 
    @Published var loading: Bool = false
//    @Published var widgetId = UUID().uuidString
    
    
    private var path = ""
    private var url = ""
    
    
    @Published var widgets: [CanvasWidget] = [imageViewTest, videoViewTest, pollViewTest, mapViewTest]
    
    
    
    func saveTempVideo(item: PhotosPickerItem, widgetId: String) {
        
        print("saving temp video")
        guard let space else { return }
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Failed load transferable")
                return
            }
            guard let videoData = try? resizeVideo(data: data) else {
                print("Failed to resize video")
                return
            }
            
            let (path, name) = try await StorageManager.shared.saveTempWidgetVideo(data: videoData, spaceId: space.spaceId, widgetId: widgetId)
            print("Saved video")
            print(path)
            let url = try await StorageManager.shared.getURLForVideo(path: path)
            
            self.path = path
            self.url = url.absoluteString
            let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid

            widgets[1] = CanvasWidget(width: 250, height: 250, borderColor: .black, userId: uid, media: .video, mediaURL: URL(string: self.url)!, widgetName: "Video Widget", widgetDescription: "Add a video")
            loading = false
        }
        
    }
    
    
    
    func saveTempImage(item: PhotosPickerItem, widgetId: String) {
      
    
        guard let space else { return }
        
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            if let image = UIImage(data: data), let imageData = resizeImage(image: image, targetSize: CGSize(width: 250, height: 250))?.jpegData(compressionQuality: 1)  {
                
                
                let (path, name) = try await StorageManager.shared.saveTempWidgetPic(data: imageData, spaceId: space.spaceId, widgetId: widgetId)
                print ("Saved Image")
                print (path)
                let url = try await StorageManager.shared.getURLForImage(path: path)
                
                self.path = path
                self.url = url.absoluteString
                let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
                
                widgets[0] = CanvasWidget(width: 250, height:  250, borderColor: .black, userId: uid, media: .image, mediaURL: URL(string: self.url)!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")
                
                
                loading = false
                
               
            }
            
            
        }
        
    }
    
    
    func saveWidget(index: Int) {
        //Need to copy to variable before uploading (something about actor-isolate whatever)
        var uploadWidget: CanvasWidget = widgets[index]
        //ensure shits are right dimensions
        uploadWidget.width = TILE_SIZE
        uploadWidget.height = TILE_SIZE
        //space call should never fail so we manly exclamation mark
        
        let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
        widgetNotification(spaceId: space!.spaceId, userUID: uid, widget: uploadWidget)
        SpaceManager.shared.uploadWidget(spaceId: space!.spaceId, widget: uploadWidget)
    }
    
    enum VideoCompressionError: Error {
        case exportSessionCreationFailed
        case compressionFailed
    }
    
    func compressVideo(inputURL: URL, outputURL: URL) throws -> URL {
        let asset = AVAsset(url: inputURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            throw VideoCompressionError.exportSessionCreationFailed;
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        
        print("GOT HERE")
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                semaphore.signal()
            } else {
                exportError = VideoCompressionError.compressionFailed
                semaphore.signal()
            }
        }
        
        semaphore.wait()
            
        if let error = exportError {
            throw error
        }
        
        return outputURL
    }

    func resizeVideo(data: Data) throws -> Data {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        try data.write(to: tempURL)
                            
        // Call your compress video function here
        let outputURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        guard let outputURL = try? compressVideo(inputURL: tempURL, outputURL: outputURL) else {
            throw VideoCompressionError.compressionFailed
        }
        return outputURL.dataRepresentation
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

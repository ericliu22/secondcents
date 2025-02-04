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


@Observable @MainActor
final class NewWidgetViewModel {
    
    var loading: Bool = false
    var widgets: [CanvasWidget] = [ imageViewTest, /*videoViewTest,*/ mapViewTest, todoViewTest, pollViewTest, calendarViewTest, textViewTest, linkViewTest, chatViewTest, tickleViewTest]
    var tempWidget: CanvasWidget?
    var latestImage: UIImage?
    var latestVideoThumbnail: UIImage?
    

    private var spaceId: String
    private var path = ""
    private var url = ""
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }

    func saveTempVideo(item: PhotosPickerItem, widgetId: String, completion: @escaping (Bool) -> Void) {
        
        print("saving temp video")
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Failed load transferable")
                return
            }
            guard let videoData = try? resizeVideo(data: data) else {
                print("Failed to resize video")
                return
            }
            
            let (path, name) = try await StorageManager.shared.saveTempWidgetVideo(data: videoData, spaceId: spaceId, widgetId: widgetId)
            print("Saved video")
            print(path)
            let url = try await StorageManager.shared.getURLForVideo(path: path)
            
            self.path = path
            self.url = url.absoluteString
            let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid

            tempWidget = CanvasWidget(width: 250, height: 250, x: 0, y: 0, borderColor: .black, userId: uid, media: .video, mediaURL: URL(string: self.url)!, widgetName: "Video Widget", widgetDescription: "Add a video")
            loading = false
            completion(true)
        }
   
    }
    
    
    
    func saveTempImage(item: PhotosPickerItem, widgetId: String, completion: @escaping (Bool) -> Void) {
      
    
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            if let image = UIImage(data: data), let imageData = resizeImage(image: image, targetSize: CGSize(width: 250, height: 250))?.jpegData(compressionQuality: 1)  {
                
                
                let (path, name) = try await StorageManager.shared.saveTempWidgetPic(data: imageData, spaceId: spaceId, widgetId: widgetId)
                print ("Saved Image")
                print (path)
                let url = try await StorageManager.shared.getURLForImage(path: path)
                
                self.path = path
                self.url = url.absoluteString
                let uid = try! AuthenticationManager.shared.getAuthenticatedUser().uid
                
                let (width, height) = SpaceManager.shared.getMultipliedSize(widthMultiplier: 1, heightMultiplier: 1)
                tempWidget = CanvasWidget(width: width, height:  height, borderColor: .black, userId: uid, media: .image, mediaURL: URL(string: self.url)!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")
                
                
                loading = false
                completion(true)
                
               
            }
           
        }
        
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
        print("OUTPUT URL: \(outputURL.absoluteString)")
        return try Data(contentsOf: outputURL)
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
    
    
    
    func loadLatestMedia() {
           PHPhotoLibrary.requestAuthorization { status in
               if status == .authorized {
                   self.loading = true
                   
                   let fetchOptions = PHFetchOptions()
                   fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                   fetchOptions.fetchLimit = 1
                   
                   let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                   
                   if let asset = fetchResult.firstObject {
                       let imageManager = PHImageManager.default()
                       
                       if asset.mediaType == .image {
                           self.loadImage(for: asset, with: imageManager)
                       } else if asset.mediaType == .video {
                           self.loadVideoThumbnail(for: asset, with: imageManager)
                       }
                   }
               }
           }
       }
    
    
    
       
       private func loadImage(for asset: PHAsset, with imageManager: PHImageManager) {
           let options = PHImageRequestOptions()
           options.isSynchronous = true
           options.deliveryMode = .highQualityFormat
           
           let targetSize = CGSize(width: 400, height: 400)
           
           imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
               if let image = image {
                   DispatchQueue.main.async {
                       self.latestImage = self.cropToSquare(image: image)
                       self.loading = false
                   }
               }
           }
       }
       
       private func loadVideoThumbnail(for asset: PHAsset, with imageManager: PHImageManager) {
           let targetSize = CGSize(width: 400, height: 400)
           
           imageManager.requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
               guard let avAsset = avAsset else {
                   DispatchQueue.main.async {
                       self.loading = false
                   }
                   return
               }
               
               let assetGenerator = AVAssetImageGenerator(asset: avAsset)
               assetGenerator.appliesPreferredTrackTransform = true
               assetGenerator.maximumSize = targetSize
               
               do {
                   let cgImage = try assetGenerator.copyCGImage(at: .zero, actualTime: nil)
                   let image = UIImage(cgImage: cgImage)
                   DispatchQueue.main.async {
                       self.latestVideoThumbnail = self.cropToSquare(image: image)
                       self.loading = false
                   }
               } catch {
                   DispatchQueue.main.async {
                       self.loading = false
                   }
               }
           }
       }
       
       private func cropToSquare(image: UIImage) -> UIImage {
           let originalWidth = image.size.width
           let originalHeight = image.size.height
           let cropSize = min(originalWidth, originalHeight)
           
           let cropRect = CGRect(
               x: (originalWidth - cropSize) / 2,
               y: (originalHeight - cropSize) / 2,
               width: cropSize,
               height: cropSize
           )
           
           guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
               return image
           }
           
           return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
       }
    
    
    
    
    
}

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


//WARNING: This is not and should not be @MainActor for a reason
//Loading times are slow asf if it is
@Observable
final class VideoWidgetViewModel {
    
    var isLoading: Bool = true
    var videoThumbnail: UIImage?
    
//    func getVideoThumbnail(from url: URL) async {
//        isLoading = true
//        let asset = AVAsset(url: url)
//        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
//        assetImgGenerate.appliesPreferredTrackTransform = true
//        
//        let time = CMTime(seconds: 1, preferredTimescale: 60)
//        
//        do {
//            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
//            let thumbnail = UIImage(cgImage: img)
//            isLoading = false
//            videoThumbnail = thumbnail
//        } catch {
//            print("Error generating thumbnail: \(error.localizedDescription)")
//            isLoading = false
//        }
//        return
//
//    }
//    
//    func getVideoThumbnail(from url: URL, maxSize: CGSize = CGSize(width: TILE_SIZE * 2, height: TILE_SIZE * 2)) async {
//        isLoading = true
//        defer {
//            isLoading = false
//        }
//
//        // Create an AVAsset with only video tracks to reduce load time
//        let asset = AVAsset(url: url)
//        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
//        assetImgGenerate.appliesPreferredTrackTransform = true
//        
//        // Reduce the size of the thumbnail for faster generation
//        assetImgGenerate.maximumSize = maxSize
//        
//        // Try to extract the image from an earlier time
//        let time = CMTime(seconds: 0.1, preferredTimescale: 15) // Faster and lower precision
//        
//        // Generate the thumbnail with a higher concurrency priority
//        do {
//            let img = try await Task(priority: .high) { () -> CGImage in
//                return try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
//            }.value
//            
//            // Update the UI thumbnail on the main thread
//            await MainActor.run {
//                videoThumbnail = UIImage(cgImage: img)
//            }
//            
//        } catch {
//            print("Error generating thumbnail: \(error.localizedDescription)")
//            videoThumbnail = nil
//        }
//    }


    
    
}

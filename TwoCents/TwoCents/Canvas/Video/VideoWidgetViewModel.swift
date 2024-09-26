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
final class VideoWidgetViewModel {
    
    var isLoading: Bool = true
    var videoThumbnail: UIImage?
    
    func getVideoThumbnail(from url: URL) async {
        isLoading = true
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            isLoading = false
            videoThumbnail = thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            isLoading = false
        }
        return

    }
    
    
}

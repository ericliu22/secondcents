//
//  CreateProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import AVFoundation
import FirebaseStorage
import Foundation
import PhotosUI
import SwiftUI

//WARNING: This is not and should not be @MainActor for a reason
//Loading times are slow asf if it is
enum FetchVideoError: Error {
    case noUrl
}

@Observable @MainActor
final class VideoWidgetViewModel {

    enum VideoState {
        case loading
        case loaded(URL)
        case error
    }

    init(spaceId: String, widget: CanvasWidget) {
        self.spaceId = spaceId
        self.widget = widget
    }

    let spaceId: String
    let widget: CanvasWidget
    var isLoading: Bool = true
    var videoThumbnail: UIImage?

    func fetchVideo() async throws {
        // 2. Let the cache manager fetch or download the local URL
        guard let mediaURL = widget.mediaURL else {
            throw FetchVideoError.noUrl
        }
        let localURL =
        try await MediaCacheManager.fetchCachedVideoURL(for: mediaURL)
        await getVideoThumbnail(from: localURL)
    }

    func getVideoThumbnail(
        from url: URL,
        maxSize: CGSize = CGSize(width: TILE_SIZE * 2, height: TILE_SIZE * 2)
    ) async {
        isLoading = true
        defer {
            isLoading = false
        }

        // Create an AVAsset with only video tracks to reduce load time
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true

        // Reduce the size of the thumbnail for faster generation
        assetImgGenerate.maximumSize = maxSize

        // Try to extract the image from an earlier time
        let time = CMTime(seconds: 0.1, preferredTimescale: 15)  // Faster and lower precision

        // Generate the thumbnail with a higher concurrency priority
        do {
            let img = try await Task(priority: .high) { () -> CGImage in
                return try assetImgGenerate.copyCGImage(
                    at: time, actualTime: nil)
            }.value

            // Update the UI thumbnail on the main thread
            await MainActor.run {
                videoThumbnail = UIImage(cgImage: img)
            }

        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            videoThumbnail = nil
        }
    }

}

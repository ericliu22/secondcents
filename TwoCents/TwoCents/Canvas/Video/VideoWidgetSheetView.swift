import AVKit
import SwiftUI

struct VideoWidgetSheetView: View {

    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .video)
        self.widget = widget
        self.spaceId = spaceId
    }

    let spaceId: String
    let widget: CanvasWidget
    @State var videoPlayer: AVPlayer?
    @State var isLoading: Bool = true
    @Environment(\.dismiss) var dismissScreen

    @Environment(CanvasPageViewModel.self) var canvasViewModel:
        CanvasPageViewModel?

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
            } else {
                if let videoPlayer {
                    VideoPlayer(player: videoPlayer)
                        .ignoresSafeArea()
                        .onDisappear {
                            videoPlayer.pause()
                        }
                }
            }
        }
        .task {
            // 1. Build the Firebase Storage reference
            do {
                guard let mediaURL = widget.mediaURL else {
                    throw FetchVideoError.noUrl
                }
                let localURL =
                try await MediaCacheManager.fetchCachedVideoURL(for: mediaURL)
                // 3. Create the AVPlayer
                let asset = AVAsset(url: localURL)
                let playerItem = AVPlayerItem(asset: asset)
                videoPlayer = AVPlayer(playerItem: playerItem)
                
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}

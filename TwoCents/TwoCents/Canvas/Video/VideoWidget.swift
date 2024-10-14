//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation

@Observable @MainActor
class VideoPlayerModel {
    var videoPlayer: AVPlayer
    var isPlaying: Bool = false
    private var playerItem: AVPlayerItem
    
    init(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        self.videoPlayer = AVPlayer(playerItem: playerItem)
        
    }
    
}


struct VideoWidget: WidgetView{
    
    @State var playerModel: VideoPlayerModel
    var widget: CanvasWidget;
    
    @State private var width: CGFloat;
    @State private var height: CGFloat;
    
    @State private var viewModel = VideoWidgetViewModel()
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
    var body: some View {
//        VideoPlayer(player: playerModel.videoPlayer)
//            .ignoresSafeArea()
//            .frame(width: width, height: height, alignment: .center)
//            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
//            .draggable(widget)
//            .onDisappear {
//                playerModel.videoPlayer.pause()
//                playerModel.isPlaying = false
//            }
        
        
        
            ZStack {
                if viewModel.isLoading {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
//                        .scaleEffect(3)
                } else {
                    if let thumbnail = viewModel.videoThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                            .ignoresSafeArea()
                            .overlay{
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.thinMaterial)
                            }
                        
                            .onTapGesture {
                                canvasViewModel.activeSheet = .video
                                canvasViewModel.activeWidget = widget
                            }
                    } else {
                        Image(systemName: "x.circle.fill")
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.getVideoThumbnail(from: widget.mediaURL!)
                }
            }
            
        
        
        
        
        
        
        
        
    }
    
    
    init(widget: CanvasWidget) {
        self.widget = widget
        self.playerModel = VideoPlayerModel(url: widget.mediaURL!)
        self.width = widget.width
        self.height = widget.height
    }
}

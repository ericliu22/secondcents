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

@Observable
class VideoPlayerModel {
    var videoPlayer: AVPlayer
    var isPlaying: Bool = false
    private var playerItem: AVPlayerItem
    
    init(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        self.videoPlayer = AVPlayer(playerItem: playerItem)
        
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeObservers()
        self.videoPlayer.pause()
    }
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
}


struct VideoWidget: WidgetView{
    var playerModel: VideoPlayerModel
    var widget: CanvasWidget;
    
    @State private var width: CGFloat;
    @State private var height: CGFloat;
    
    private var viewModel = VideoWidgetViewModel()
    @Environment(CanvasPageViewModel.self) var canvasViewModel: CanvasPageViewModel?
    
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
                if let videoThumbnail = viewModel.videoThumbnail {
                    Image(uiImage: videoThumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                        .ignoresSafeArea()
                        .draggable(widget) // Assuming you want to drag the URL
                    
                        .overlay{
                            Image(systemName: "play.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.thinMaterial)
                        }
                    
                    
                        .onTapGesture {
                            guard let canvasViewModel = canvasViewModel else { return }
                            canvasViewModel.activeSheet = .video
                            canvasViewModel.activeWidget = widget
                        }
                } else {
                        Text("Unable to load thumbnail")
                            .frame(width: width, height: height)
                            .background(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                }
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(3)
                }
            }
            .task {
                await viewModel.getVideoThumbnail(from: widget.mediaURL!)
            }
            
        
        
        
        
        
        
        
        
    }
    
    
    init(widget: CanvasWidget) {
        self.widget = widget
        self.playerModel = VideoPlayerModel(url: widget.mediaURL!)
        self.width = widget.width
        self.height = widget.height
    }
}

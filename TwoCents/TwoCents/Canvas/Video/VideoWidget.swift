//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import AVKit

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
    
    var body: some View {
        VideoPlayer(player: playerModel.videoPlayer)
            .ignoresSafeArea()
            .frame(width: width, height: height, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
            .draggable(widget)
            .onDisappear {
                playerModel.videoPlayer.pause()
                playerModel.isPlaying = false
            }
    }
    
    
    init(widget: CanvasWidget) {
        self.widget = widget
        self.playerModel = VideoPlayerModel(url: widget.mediaURL!)
        self.width = widget.width
        self.height = widget.height
    }
}

//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import AVKit

class VideoPlayerModel: ObservableObject {
    var videoPlayer: AVPlayer
    @Published var isPlaying: Bool = false
    private var playerItem: AVPlayerItem
    
    init(url: URL) {
        let asset = AVAsset(url: url)
        self.playerItem = AVPlayerItem(asset: asset)
        self.videoPlayer = AVPlayer(playerItem: playerItem)
    }
    
    deinit {
        self.videoPlayer.pause()
    }
}


struct VideoWidget: WidgetView{
    @ObservedObject private var playerModel: VideoPlayerModel

    var widget: CanvasWidget;
    private var width: CGFloat;
    private var height: CGFloat;
    private var newWidget: Bool;
    
    var body: some View {
        if newWidget {
            VideoPlayer(player: playerModel.videoPlayer)
                .ignoresSafeArea()
                .frame(width: width, height: height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                .draggable(widget)
        } else {
            VideoPlayer(player: playerModel.videoPlayer)
                .ignoresSafeArea()
                .frame(width: width, height: height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                .draggable(widget)
                .gesture(TapGesture().onEnded({
                    playerModel.videoPlayer.isMuted.toggle()
                    playerModel.isPlaying.toggle()
                    if playerModel.isPlaying {
                        playerModel.videoPlayer.play()
                    } else {
                        playerModel.videoPlayer.pause()
                    }
                }))
        }
    }
    
    
    init(widget: CanvasWidget, newWidget: Bool) {
        print("Initialized Video Widget")
        self.widget = widget
        self.newWidget = newWidget
        self.playerModel = VideoPlayerModel(url: widget.mediaURL!)
        self.width = widget.width
        self.height = widget.height
    }
}

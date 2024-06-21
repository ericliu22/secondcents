//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import AVKit

struct VideoWidget: WidgetView{
    
    private var videoPlayer: AVQueuePlayer
    private var playerLooper: AVPlayerLooper
    var widget: CanvasWidget;
    private var width: CGFloat;
    private var height: CGFloat;
    private var newWidget: Bool;
    
    var body: some View {
        if newWidget {
            VideoPlayer(player: videoPlayer)
                .ignoresSafeArea()
                .frame(width: width, height: height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                .draggable(widget)
        } else {
            VideoPlayer(player: videoPlayer)
                .ignoresSafeArea()
                .frame(width: width, height: height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                .draggable(widget)
                .gesture(TapGesture().onEnded({
                    videoPlayer.isMuted.toggle()
                }))
        }
    }
    
    
    init(widget: CanvasWidget, newWidget: Bool) {
        self.widget = widget
        self.newWidget = newWidget
        let asset: AVAsset = AVAsset(url: widget.mediaURL!)
        let playerItem = AVPlayerItem(asset: asset)
        self.videoPlayer = AVQueuePlayer(playerItem: playerItem)
        self.playerLooper = AVPlayerLooper(player: videoPlayer, templateItem: playerItem)
        self.videoPlayer.play()
        self.videoPlayer.isMuted = true
        self.width = widget.width
        self.height = widget.height
    }
}

//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import AVKit

struct VideoWidget: View{
    
    var url: URL;
    var videoplayer: AVPlayer;
    var width: CGFloat;
    var height: CGFloat;
    @State private var isPlaying = false;
    
    var body: some View {
        VideoPlayer(player: videoplayer)
            .ignoresSafeArea()
                 
            .frame(width: width, height: height, alignment: .center)
        
            
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
          
        
            .gesture(TapGesture().onEnded({
                isPlaying ? videoplayer.pause() : videoplayer.play()
                isPlaying.toggle()
                
            })).draggable(url)
        
        
    }
    
    
    init(url: URL, width: CGFloat, height: CGFloat) {
        self.url = url
        self.videoplayer = AVPlayer(url: self.url)
        self.width = width
        self.height = height
        
        
    }
    
}

func videoWidget(widget: CanvasWidget) -> AnyView {
        assert(widget.media == .video)
        var isPlaying = true
        let videoplayer = AVPlayer(url: widget.mediaURL)
        return AnyView(
            VideoPlayer(player: videoplayer)
                .frame(width: widget.width ,height: widget.height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
                .gesture(TapGesture().onEnded({
                    isPlaying ? videoplayer.pause() : videoplayer.play()
                    isPlaying.toggle()
                })).draggable(widget)
        )
}

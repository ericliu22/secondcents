//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import AVKit

class VideoWidget: CanvasWidget {
    
    
    struct VideoView: View {
        @State var isPlaying: Bool = false
        @State var privatePlayer: AVPlayer
        var width: CGFloat
        var height: CGFloat
        
        init(url: URL, width: CGFloat, height: CGFloat) {
            self.isPlaying = false
            self.privatePlayer = AVPlayer(url: url)
            self.width = width
            self.height = height
        }
        
        var body: some View {
            VideoPlayer(player: privatePlayer)
                .frame(width: width,height: height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .gesture(TapGesture().onEnded({
                    isPlaying ? privatePlayer.pause() : privatePlayer.play()
                    isPlaying.toggle()
                }))
        }
        
    }
    
    init(position: CGPoint, size: [CGFloat], borderColor: Color, videoName: String, extensionName: String) {
        let filePath = Bundle.main.path(forResource: videoName, ofType: extensionName)
        
        let videoURL = URL(filePath: "lisa manoban.mp4")
        let bodyView = AnyView(
            ZStack {
                VideoView(url: videoURL, width: size[0], height: size[1])
                Image(systemName: "play")
            }
        )
        
        super.init(position: position, borderColor: borderColor, bodyView: bodyView)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: Decoder.self as! Decoder);
    }
}

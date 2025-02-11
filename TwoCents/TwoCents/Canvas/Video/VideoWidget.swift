//
//  VideoWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI

struct VideoWidget: WidgetView {

    let widget: CanvasWidget
    let width: CGFloat
    let height: CGFloat

    @State var viewModel: VideoWidgetViewModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel

    init(widget: CanvasWidget, spaceId: String) {
        self.widget = widget
        self.width = widget.width
        self.height = widget.height

        self.viewModel = VideoWidgetViewModel(spaceId: spaceId, widget: widget)
    }

    var body: some View {

        ZStack {
            if viewModel.isLoading {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .primary))
                //                        .scaleEffect(3)
            } else {
                if let thumbnail = viewModel.videoThumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height, alignment: .center)
                        .clipShape(
                            RoundedRectangle(cornerRadius: CORNER_RADIUS)
                        )
                        .ignoresSafeArea()
                        .overlay {
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
        .task {
            
            // 3. Create the AVPlayer
            do {
                try await viewModel.fetchVideo()
                viewModel.isLoading = false
            } catch {
                viewModel.isLoading = false
            }
        }
    }

}

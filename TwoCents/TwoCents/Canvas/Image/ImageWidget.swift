//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

struct ImageWidget: WidgetView {

    let widget: CanvasWidget
    let spaceId: String

    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .image)
        self.widget = widget
        self.spaceId = spaceId
    }

    @Environment(CanvasPageViewModel.self) var canvasViewModel:
        CanvasPageViewModel?

    var body: some View {
        if let mediaURL = widget.mediaURL {
            CachedImage(imageUrl: mediaURL)
                .frame(width: widget.width, height: widget.height)
                .onTapGesture {
                    guard let canvasViewModel = canvasViewModel else { return }
                    canvasViewModel.activeSheet = .image
                    canvasViewModel.activeWidget = widget
                }
        }
    }
}

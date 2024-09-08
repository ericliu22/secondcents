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
    
    init(widget: CanvasWidget) {
        assert(widget.media == .image)
        self.widget = widget
    }
    
    @Environment(CanvasPageViewModel.self) var canvasViewModel: CanvasPageViewModel?
    
    var body: some View {
        AsyncImage(url: widget.mediaURL) {image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: widget.width, height: widget.height)
                .clipShape(
                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
                )
        } placeholder: {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint:
                            .primary)
                )
           
                .frame(width: widget.width, height: widget.height)
                .background(.thickMaterial)
        }//AsyncImage
        .onTapGesture {
            guard let canvasViewModel = canvasViewModel else { return }
            canvasViewModel.activeSheet = .image
            canvasViewModel.activeWidget = widget
        }
    }
}

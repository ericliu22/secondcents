//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

func imageWidget(widget: CanvasWidget) -> AnyView {

//    print(isPresented)
    assert(widget.media == .image)
    

    
    return AnyView(
        
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
          
       
    )//AnyView
    
}

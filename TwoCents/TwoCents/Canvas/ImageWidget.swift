//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

class ImageWidget: CanvasWidget {
    
    init(position: CGPoint, size: [CGFloat], borderColor: Color, image: Image) {
        let bodyView: AnyView = {
            AnyView(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size[0], height: size[1])
                    .clipShape(
                        RoundedRectangle(cornerRadius: 25)
                    )
                )
        }()
        super.init(position: position, size: size, borderColor: borderColor, bodyView: bodyView)
    }
}


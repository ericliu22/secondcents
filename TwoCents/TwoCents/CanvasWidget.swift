//
//  Widget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/17.
//

import Foundation
import SwiftUI

/**
The default inherited class for all widgets on the Canvas. Don't actually initialize this class
 it's not actually a view so you have to use the ```widgetView()```
 function to get the view
 
 > Warning: Don't fuck up the size. It's always [width, height].
 There are no safety measures for this.
 
 -  Parameters:
    - position: A CGPoint
    - borderColor: Color of the user
    - size: Always make it an int list length 2 of [width, height]. There are no safety measures for this just remember it well
    - bodyView: The actual content of the widget
 */
class CanvasWidget {
    
    var position: CGPoint
    var size: [CGFloat] = []
    var borderColor: Color
    var bodyView: AnyView
    var userId: String
    
    func widgetView() -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(borderColor, lineWidth: 10)
                    .frame(width: size[0], height: size[1])
                self.bodyView
            }.position(x: position.x, y: position.y)
        )
    }
    init(position: CGPoint, size: [CGFloat], borderColor: Color, bodyView: AnyView) {
        self.position = position
        self.borderColor = borderColor
        self.bodyView = bodyView
        self.userId = "gay"
        self.size = size
    }
}



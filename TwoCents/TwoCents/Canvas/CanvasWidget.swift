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
class CanvasWidget: Hashable, Codable, Identifiable, Transferable, Equatable {
    static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .content)
    }
    
    
    var uid: String
    var position: CGPoint
    var size: [CGFloat] = [250,250]
    var borderColor: Color
    var bodyView: AnyView
    var userId: String
    var media: String
    
    func widgetView() -> AnyView {
        AnyView(
            ZStack {
                
                self.bodyView
                RoundedRectangle(cornerRadius: 25)
                    .stroke(borderColor, lineWidth: 10)
                    .frame(width: size[0], height: size[1])
            }
        )
    }
    
    enum CodingKeys: String, CodingKey {
        
        case uid
        case positionX
        case positionY
        case borderColor
        case userId
        case media
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        let x: Float = try container.decode(Float.self, forKey: .positionX)
        let y: Float = try container.decode(Float.self, forKey: .positionY)
        self.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
        self.borderColor = Color.fromString(name: try container.decode(String.self, forKey: .borderColor))
        self.media = try container.decode(String.self, forKey: .media)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.bodyView = AnyView(ZStack{})
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(uid, forKey: .uid)
            try container.encode(position.x, forKey: .positionX)
            try container.encode(position.y, forKey: .positionY)
            try container.encode(userId, forKey: .userId)
            try container.encode(media, forKey: .media)
            try container.encode(borderColor.description, forKey: .borderColor)
    }
    
    init(position: CGPoint, borderColor: Color, bodyView: AnyView) {
        self.position = position
        self.borderColor = borderColor
        self.bodyView = bodyView
        self.userId = "HfQw46R2aGfUK2CWNTPJ7LU8cGA3"
        self.uid = UUID().uuidString
        self.media = ""
    }
    
    static func == (lhs: CanvasWidget, rhs: CanvasWidget) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}


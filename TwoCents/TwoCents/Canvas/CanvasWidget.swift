//
//  Widget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/17.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/**
The default class for all widgets on the Canvas.
 It's not actually a view so you have to use the ```getMediaView(widget: CanvasWidget)```
 function to get the view
 
 > Warning: Decoder and Encoder has untested behavior might not work.
 There are no safety measures for this.
 
 -  Parameters:
    - id: UUID of the widget which will also be the UUID on firestore (i.e. interchangable). Don't change this when doing copy-remove behavior in arrays
    - width: Length of the widget
    - height: Height of the widget
    - borderColor: Color of the user
    - uid: The user owner of the widget's id
    - media: An enumerator that describes what function to call to get the view (e.g. .video or .image)
    - mediaURL: URL type that is a link to the media attached to widget
 */
struct CanvasWidget: Hashable, Codable, Identifiable, Transferable, Equatable {
    
    static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .canvasWidget)
    }
    
    
    var id: UUID = UUID()
    var width: CGFloat
    var height: CGFloat
    var borderColor: Color
    var userId: String
    var media: Media
    var mediaURL: URL
    
    
    
    static func == (lhs: CanvasWidget, rhs: CanvasWidget) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum Media {
    case video, image
}

extension Media: Codable {
    init (media: String) {
        switch media {
            case "video":
                self = .video
            case "image":
                self = .image
            default:
                self = .image
        }
    }
    
}

extension CanvasWidget {

    enum CodingKeys: String, CodingKey {
        
        case id
        case borderColor
        case userId
        case media
        case mediaURL
        case width
        case height
        
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.borderColor = Color.fromString(name: try container.decode(String.self, forKey: .borderColor))
        self.userId = try container.decode(String.self, forKey: .userId)
        self.media = try container.decode(Media.self, forKey: .media)
        self.mediaURL = try container.decode(URL.self, forKey: .mediaURL)
        self.width = try container.decode(CGFloat.self, forKey: .width)
        self.height = try container.decode(CGFloat.self, forKey: .height)
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(userId, forKey: .userId)
            try container.encode(borderColor.description, forKey: .borderColor)
            try container.encode(media, forKey: .media)
            try container.encode(mediaURL, forKey: .mediaURL)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
    }
    
}

extension UTType {
    static let canvasWidget = UTType(exportedAs: "com.twocentsapp.secondcents")
}

func getMediaView(widget: CanvasWidget) -> AnyView {
    switch (widget.media) {
    case .video:
        return videoWidget(widget: widget)
    case .image:
        return imageWidget(widget: widget)
    }
}

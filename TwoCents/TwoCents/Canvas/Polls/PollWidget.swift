//
//  PollWidget.swift
//  TwoCents
//
//  Created by Joshua Shen on 1/11/24.
//

import Foundation
import SwiftUI
import UIKit
import Charts



struct PollWidget: View {
    
    
    
    private var spaceId: String
    private var widget: CanvasWidget
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .poll)
        self.widget = widget
        self.spaceId = spaceId
    
        
    }
    
    
    
    
    var body: some View {
        ZStack{
            
            
            Color.blue
            Text(widget.widgetName!)
            
            
            
            
        }
        
        .frame(width: widget.width, height: widget.height)
        
    
        
    }
}









func pollWidget(widget: CanvasWidget, spaceId: String) -> AnyView {
    return AnyView(PollWidget(widget: widget, spaceId: spaceId))
    
}



struct PollWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        pollWidget(widget: CanvasWidget(id: UUID(uuidString: "B2A0B128-5877-4312-8FE4-9D66AEC76768")!, width: 150.0, height: 150.0, borderColor: .orange, userId: "zqH9h9e8bMbHZVHR5Pb8O903qI13", media: TwoCents.Media.poll, mediaURL: nil, widgetName: Optional("Yo"), widgetDescription: nil, textString: nil, emojis: ["👍": 0, "👎": 0, "😭": 1, "❤️": 0, "🫵": 1, "⁉️": 0], emojiPressed: ["⁉️": [], "❤️": [], "🫵": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👎": [], "😭": ["zqH9h9e8bMbHZVHR5Pb8O903qI13"], "👍": []]), spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
    }
}


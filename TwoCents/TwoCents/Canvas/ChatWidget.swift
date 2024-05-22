//
//  ChattingWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/11/27.
//

import Foundation
import SwiftUI

func chatWidget(widget: CanvasWidget) -> AnyView {
    assert(widget.media == .chat)
    
    return AnyView(
        ChatView(spaceId: "87D5AC3A-24D8-4B23-BCC7-E268DBBB036F", replyMode: .constant(false), replyWidget: .constant(nil))
    )//AnyView
    
}

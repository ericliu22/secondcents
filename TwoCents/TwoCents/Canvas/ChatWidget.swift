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
        ChatView()
    )//AnyView
    
}

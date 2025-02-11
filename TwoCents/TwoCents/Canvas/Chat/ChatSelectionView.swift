//
//  ChatWidgetSelectionView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/1.
//

import SwiftUI

struct ChatSelectionView: View {

    @Environment(CanvasPageViewModel.self) var canvasViewModel

    var body: some View {
        let chatWidgets = canvasViewModel.canvasWidgets.filter({
            $0.media == .chat
        })
        List {
            ForEach(chatWidgets) { chatWidget in
                NavigationLink {
                    ChatPage()
                        .onAppear {
                            canvasViewModel.activeSheet = nil
                            canvasViewModel.inSubView = true
                            canvasViewModel.replyWidget = chatWidget
                        }
                        .onDisappear {
                            canvasViewModel.inSubView = false
                            canvasViewModel.replyWidget = nil
                        }
                        .environment(
                            ChatWidgetViewModel(
                                spaceId: canvasViewModel.spaceId,
                                chatId: chatWidget.id.uuidString)
                        )
                        .environment(canvasViewModel)
                } label: {
                    Text(chatWidget.widgetName ?? "")
                }
            }
        }
    }
}

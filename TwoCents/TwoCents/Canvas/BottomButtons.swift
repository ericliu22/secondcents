//
//  RecentChatButton.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/10.
//

import FirebaseFirestore
import SwiftUI

struct BottomButtons: View {
    @Environment(CanvasPageViewModel.self) var viewModel
    @Environment(AppModel.self) var appModel
    
    @ViewBuilder
    func NormalButtons() -> some View {
        HStack {
            if let lastChatId = viewModel.lastChatId {
                NavigationLink {
                    ChatPage()
                        .environment(
                            ChatWidgetViewModel(
                                spaceId: viewModel.spaceId,
                                chatId: lastChatId)
                        )
                        .environment(viewModel)
                        .onAppear {
                            if let index = viewModel.unreadWidgets
                                .firstIndex(
                                    of: lastChatId)
                            {
                                viewModel.unreadWidgets.remove(at: index)
                                Task {
                                    guard let userId = appModel.user?.userId
                                    else {
                                        return
                                    }
                                    await readWidgetUnread(
                                        spaceId: viewModel.spaceId,
                                        userId: userId, widgetId: lastChatId
                                    )
                                }
                            }
                        }
                } label: {
                    Image(systemName: "bubble.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(appModel.loadedColor)
                }
            }
            
            Button {
                viewModel.activeSheet = .newWidgetView(startingLocation: nil)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(appModel.loadedColor)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    var body: some View {
        HStack {
            if viewModel.canvasMode == .placement {
                Button(
                    action: {
                        viewModel.confirmPlacement(x: viewModel.widgetCursor.x, y: viewModel.widgetCursor.y)
                    },
                    label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.green)
                    }
                )
                Button(
                    action: {
                        viewModel.canvasMode = .normal
                        guard let newWidget = viewModel.newWidget else {
                            return
                        }
                        SpaceManager.shared.deleteAssociatedWidget(
                            spaceId: viewModel.spaceId,
                            widgetId: newWidget.id.uuidString,
                            media: newWidget.media)
                    },
                    label: {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.red)
                    }
                )
            }
            if viewModel.canvasMode == .normal {
                NormalButtons()
            }
        }
        .background(Color.clear)
        .padding(.bottom, 20)
        .contentMargins(50)
    }
    
}

//
//  NewChatWidgetView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/16.
//
import SwiftUI

struct NewChatWidgetView: View {
    @State var viewModel: NewChatWidgetViewModel = NewChatWidgetViewModel()
    @Environment(AppModel.self) var appModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel

    @Binding var closeNewWidgetView: Bool
    let spaceId: String

    init(spaceId: String, closeNewWidgetView: Binding<Bool>) {
        self.spaceId = spaceId
        self._closeNewWidgetView = closeNewWidgetView
    }

    var body: some View {
        TextField("Enter a name", text: $viewModel.text)
        Button {
            print("Uploading chat")
            guard
                let widget = try? viewModel.uploadChat(
                    userId: appModel.user!.userId, spaceId: spaceId)
            else {
                return
            }
            canvasViewModel.newWidget = widget
            canvasViewModel.canvasMode = .placement
            closeNewWidgetView = true
            
        } label: {
            Text("Create")
                .font(.headline)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
        }
        .disabled(viewModel.text.isEmpty)
        .buttonStyle(.bordered)
        .tint(.accentColor)
    }
}

struct NewChatWidgetPreview: View {
    @Environment(AppModel.self) var appModel
    let spaceId: String
    @Binding var closeNewWidgetView: Bool
    
    var body: some View {
        ZStack {
            NavigationLink {
                NewChatWidgetView(spaceId: spaceId, closeNewWidgetView: $closeNewWidgetView)
            } label: {
                ChatPreview(messages: [
                    TextMessage(sendBy: "Joe", text: "Heyyy"),
                    TextMessage(
                        sendBy: appModel.user?.userId ?? "",
                        text: "Stop contacting me"),
                ])
                .cornerRadius(20)
            }
        }
    }
}

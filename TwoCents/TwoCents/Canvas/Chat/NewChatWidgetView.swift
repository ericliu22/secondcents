//
//  NewChatWidgetView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/16.
//

import SwiftUI

struct NewChatWidgetView: View {
    
    @Environment(AppModel.self) var appModel
    let spaceId: String
    @Binding var closeNewWidgetView: Bool
    
    @State var viewModel: NewChatWidgetViewModel = NewChatWidgetViewModel()
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @State private var showingView: Bool = false

    init(spaceId: String, closeNewWidgetView: Binding<Bool>) {
        self.spaceId = spaceId
        self._closeNewWidgetView = closeNewWidgetView
    }

    var body: some View {
        NewChatPreview()
            .onTapGesture { showingView.toggle() }
            .fullScreenCover(isPresented: $showingView) {
                NavigationStack {
                    VStack(spacing: 20) {
                        TextField("Enter a name", text: $viewModel.text)
                            .padding(.horizontal)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)

                        Button {
                            print("Uploading chat")
                            guard let user = appModel.user else {
                                return
                            }
                            guard let widget = try? viewModel.uploadChat(userId: user.userId, spaceId: spaceId) else {
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
                    .padding()
                    .navigationTitle("New Chat")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showingView = false }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
    }
}

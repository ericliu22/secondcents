import SwiftUI

struct MessageField: View {
    
    @StateObject private var viewModel = MessageFieldViewModel()
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(ChatViewModel.self) var chatViewModel
    @Environment(AppModel.self) var appModel
    
    @State private var message = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField(chatViewModel.threadId == "" ? "Message" : "Reply", text: $message, axis: .vertical)
                .lineLimit(0...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .padding(.trailing, 48)
                .font(.headline)
                .fontWeight(.regular)
                .focused($isFocused)
            
            Button {
                Task {
                    await viewModel.sendMessages(text: message, widget: canvasViewModel.replyWidget, spaceId: chatViewModel.spaceId, threadId: chatViewModel.threadId)
                    
                    // Ensure message and widget clear on the main thread
                    DispatchQueue.main.async {
                        message = ""
                        canvasViewModel.replyWidget = nil
                    }
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.headline)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(message.isEmpty && canvasViewModel.replyWidget == nil ? .clear : .white)
                    .background(message.isEmpty && canvasViewModel.replyWidget == nil ? .clear : appModel.loadedColor)
                    .clipShape(Circle())
                    .padding(.bottom, 4)
            }
            .clipped()
            .buttonStyle(PlainButtonStyle())
            .disabled(message.isEmpty && canvasViewModel.replyWidget == nil)
            .padding(.trailing, 5)

        }
        .foregroundStyle(Color(UIColor.label))
        .background(.regularMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 5)
        .frame(minHeight: 50, alignment: .center)
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .background(.clear)
        .onChange(of: chatViewModel.threadId) { oldValue, newValue in
            if newValue != "" {
                isFocused = true
            }
        }
        
        .onChange(of: canvasViewModel.replyWidget) { _, newValue in
            if newValue != nil {
                isFocused = true
            }
        }
        
      
    }
}



//#Preview {
//    NewMessageField()
//}

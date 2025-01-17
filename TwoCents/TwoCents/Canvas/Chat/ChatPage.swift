import SwiftUI

struct ChatPage: View {

    @Environment(ChatWidgetViewModel.self) var viewModel
    @FocusState var isFocused: Bool

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            List {
                ForEach(viewModel.messages, id: \.id) { message in
                    makeMessage(message: message)
                        .rotationEffect(.degrees(180))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            }
            .rotationEffect(.degrees(180))
            
            ZStack(alignment: .bottomTrailing) {
                TextField(
                    "Message",
                    text: $viewModel.message, axis: .vertical
                )
                .lineLimit(0...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .padding(.trailing, 48)
                .font(.headline)
                .fontWeight(.regular)
                .focused($isFocused)
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(
                            viewModel.message.isEmpty ? .clear : .white
                        )
                        .background(
                            viewModel.message.isEmpty ? .clear : .purple
                            //@TODO: This is supposed to be appModel.loadedColor
                        )
                        .clipShape(Circle())
                        .padding(.bottom, 4)
                }
                .clipped()
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.message.isEmpty)
                .padding(.trailing, 5)
                
            }
            .foregroundStyle(Color(UIColor.label))
            .background(.regularMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 5)
            .frame(minHeight: 50, alignment: .center)
            
        }
        .frame(maxHeight: .infinity)
    }

}

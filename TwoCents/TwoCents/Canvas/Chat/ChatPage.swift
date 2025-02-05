import SwiftUI

struct ChatPage: View {

    @Environment(ChatWidgetViewModel.self) var viewModel
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @Environment(AppModel.self) var appModel
    @FocusState var isFocused: Bool

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.messages, id: \.id) { message in
                        makeMessage(message: message)
                            .rotationEffect(.degrees(180))
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 0, leading: 0, bottom: 0, trailing: 0)
                            )
                            .listRowBackground(Color.clear)
                            .frame(maxWidth: .infinity, alignment: appModel.user?.userId == message.sendBy ? .leading : .trailing)
                            .environment(canvasViewModel)
                            .environment(viewModel)
                    }
                }
                .rotationEffect(.degrees(180))
            }
            .navigationTitle(viewModel.chat?.name ?? "")
            .scrollIndicators(.hidden)

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
                    guard let user = appModel.user else {
                        return
                    }
                    viewModel.sendMessage(userId: user.userId)
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(
                            viewModel.message.isEmpty ? .clear : .white
                        )
                        .background(
                            viewModel.message.isEmpty
                                ? .clear : appModel.loadedColor
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

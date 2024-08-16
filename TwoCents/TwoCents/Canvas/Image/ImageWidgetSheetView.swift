import SwiftUI

struct ImageWidgetSheetView: View {
    
    private var spaceId: String
    private var widget: CanvasWidget
    
    @State private var user: DBUser? = nil
    @Environment(\.dismiss) var dismissScreen
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .image)
        self.widget = widget
        self.spaceId = spaceId
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                AsyncImage(url: widget.mediaURL) { image in
                    image
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .primary)
                        )
                } // AsyncImage
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismissScreen()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor.label))
                    })
                }
            }
            .navigationTitle(user?.name ?? "Loading...")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
            .task {
                do {
                    let fetchedUser = try await UserManager.shared.getUser(userId: widget.userId)
                    user = fetchedUser // Update the state variable
                } catch {
                    print("Failed to get user: \(error.localizedDescription)")
                }
            }
        }
    }
}

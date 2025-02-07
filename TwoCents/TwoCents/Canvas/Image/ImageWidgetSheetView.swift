import SwiftUI

struct ImageWidgetSheetView: View {
    
    let spaceId: String
    let widget: CanvasWidget
    
    @Environment(\.dismiss) var dismissScreen
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .image)
        self.widget = widget
        self.spaceId = spaceId
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if let mediaURL = widget.mediaURL {
                        CachedUrlImage(imageUrl: mediaURL)
                    }
                }
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
            .navigationTitle(canvasViewModel.members[id: widget.userId]?.name ?? "Photo")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)

        }
    }
}

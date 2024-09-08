import SwiftUI
import AVKit

struct VideoWidgetSheetView: View {
    
    init(widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .video)
        self.widget = widget
        self.spaceId = spaceId
        self.playerModel = VideoPlayerModel(url: widget.mediaURL!)
    }
    
    private var spaceId: String
    private var widget: CanvasWidget
    
    @State private var user: DBUser? = nil
    @Environment(\.dismiss) var dismissScreen
    
    private var playerModel: VideoPlayerModel
  
    var body: some View {
        NavigationStack {
            VideoPlayer(player: playerModel.videoPlayer)
                .ignoresSafeArea()
                .onDisappear {
                    playerModel.videoPlayer.pause()
                    playerModel.isPlaying = false
                }
               
//                .background(.black)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        dismissScreen()
//                    }, label: {
//                        Image(systemName: "xmark")
////                            .foregroundColor(Color(UIColor.label))
//                            .foregroundColor(.white)
//                    })
//                }
//            }
          
//            .navigationTitle(user?.name ?? "Loading...")
//            
//            .navigationBarTitleDisplayMode(.inline)
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

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
    
    
    @Environment(CanvasPageViewModel.self) var canvasViewModel: CanvasPageViewModel?
    
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
         
        }
    }
}

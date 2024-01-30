//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import PencilKit


//CONSTANTS
let db = Firestore.firestore()

let TILE_SIZE: CGFloat = 100
let MAX_ZOOM: CGFloat = 3.0
let MIN_ZOOM: CGFloat = 1.0
let CORNER_RADIUS: CGFloat = 15
let LINE_WIDTH: CGFloat = 5
let FRAME_SIZE: CGFloat = 1000

//HARDCODED SECTION


var imageView0 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!)
var imageView1 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://www.billboard.com/wp-content/uploads/2023/01/lisa-blackpink-dec-2022-billboard-1548.jpg?w=942&h=623&crop=1")!)
var imageView2 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://i.mydramalist.com/66L5p_5c.jpg")!)
var imageView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://static.wikia.nocookie.net/the_kpop_house/images/6/60/Jisoo.jpg/revision/latest?cb=20200330154248")!)

var videoView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://video.link/w/vl6552d3ab6cdff#")!)

var chatview = CanvasWidget(borderColor: .blue, userId: "shenjjj", media: .chat, mediaURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)
//HARDCODED SECTION




func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}



struct CanvasPage: View {
    
    
    
    @State private var userUID: String = ""
    @State var canvas: PKCanvasView = PKCanvasView()
    @State var toolPickerActive: Bool = false
    @State private var currentMode: canvasState = .normal
    @State private var canvasWidgets: [CanvasWidget] = []
    @State private var draggingItem: CanvasWidget?
    @State private var scrollPosition: CGPoint = CGPointZero
    @State private var activeGestures: GestureMask = .none
    @State private var showNewWidgetView: Bool = false
    @State private var photoLinkedToProfile: Bool = false
    @State private var widgetId: String = UUID().uuidString
    
    
    
    private var spaceId: String
    
    
    @State private var newWidget: Bool = false
    @State private var widgetShake: Double = 0
    private var chatroomDocument: DocumentReference
    private var drawingDocument: DocumentReference
    
    enum canvasState {
        
        case drawing, grab, normal
        
    }
    
    init(spaceId: String) {
        self.spaceId = spaceId
        
        self.chatroomDocument = db.collection("spaces").document(spaceId)
        self.drawingDocument = db.collection("spaces").document(spaceId).collection("Widgets").document("Drawings")
        let pullDrawing = db.collection("spaces").document(spaceId).addSnapshotListener {
            documentSnapshot, error in guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Empty document")
                return
            }
        }
        
    }
    
    func pushDrawing(userId: String, userColor: Color, lines: [Line]) {
        
    }

    func onChange() async {
        self.canvasWidgets = [imageView0, imageView1, imageView2, imageView3, videoView3, chatview]
    }
    
    
    
    func GridView() -> AnyView {
        
        let columns = Array(repeating: GridItem(.fixed(TILE_SIZE), spacing: 15, alignment: .leading), count: 3)
        
        return AnyView(LazyVGrid(columns: columns, alignment: .leading, spacing: 15, content: {
            
            ForEach(canvasWidgets, id:\.id) { widget in
                
                ZStack {
                    getMediaView(widget: widget)
                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
                        .stroke(widget.borderColor, lineWidth: LINE_WIDTH)
                        .frame(width: widget.width, height: widget.height)
                }
                .phaseAnimator([false, true], trigger: currentMode == .grab) { content, phase in
                    content.rotationEffect(.degrees(phase ? -5 : 0))
                } animation: { phase in
                    phase ? .linear(duration: 0.1).repeatForever(autoreverses: true) : .default
                }

                .draggable(widget) {
                    getMediaView(widget: widget).onAppear{
                        self.currentMode = .grab
                        draggingItem = widget
                    }
                }.dropDestination(for: CanvasWidget.self) { items, location in
                    draggingItem = nil
                    return false
                } isTargeted: { status in
                    if let draggingItem, status, draggingItem != widget {
                        if let sourceIndex = canvasWidgets.firstIndex(of: draggingItem),
                           let destinationIndex = canvasWidgets.firstIndex(of: widget) {
                            withAnimation(.bouncy) {
                                let sourceItem = canvasWidgets.remove(at: sourceIndex)
                                canvasWidgets.insert(sourceItem, at: destinationIndex)
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(widgetShake))
            }
        }
                                ))
    }
    
    func Toolbar() -> AnyView {
        
        AnyView(
            HStack{
                    Image(systemName: "pencil.circle")
                        .font(.largeTitle)
                        .foregroundColor(currentMode == .drawing ? .red : .black)
                        .gesture(TapGesture(count: 1).onEnded({
                            self.toolPickerActive.toggle()
                            print("Canvas Page TOOLPICKERACTIVE \(toolPickerActive)")
                            if currentMode != .drawing {
                                self.currentMode = .drawing
                                self.activeGestures = .all
                            } else {
                                self.currentMode = .normal
                                self.activeGestures = .subviews
                            }
                        }))
                    Image(systemName: "hand.raised\(currentMode == .grab ? ".fill" : "")")
                        .font(.largeTitle)
                        .foregroundColor(Color.black)
                        .gesture(TapGesture(count: 1).onEnded({
                            if currentMode == .grab {
                                currentMode = .normal
                                widgetShake = 0
                            } else {
                                self.currentMode = .grab
                                self.activeGestures = .subviews
                            }
                        }))
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .gesture(TapGesture(count:1).onEnded(({
                            
                            showNewWidgetView = true
                        })))
            }
            
        )
        
    }
    
    func canvasView() -> AnyView {
        
       return AnyView(
        ScrollView([.horizontal,.vertical], content: {
            ZStack {
                GridView()
                    .zIndex(currentMode == .grab ? 1 : 0)
                if (currentMode != .grab) {
                    DrawingCanvas(canvas: $canvas, toolPickerActive: $toolPickerActive).allowsHitTesting(toolPickerActive)
                }
            }
            //            .gesture(scroll, including: activeGestures)
        }).scrollDisabled(currentMode != .normal)
        )
    }
    
    var body: some View {
        
        VStack{
            Toolbar()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
            canvasView()
                .task {
                    await onChange()
                }
        }
        .sheet(isPresented: $showNewWidgetView, onDismiss: {
            
            if photoLinkedToProfile {
                photoLinkedToProfile = false
                widgetId = UUID().uuidString
                
            } else {
                Task{
                    try await StorageManager.shared.deleteTempWidgetPic(spaceId:spaceId, widgetId: widgetId)
                }
            }
            
            
        }, content: {
            
            NewWidgetView(widgetId: widgetId, showNewWidgetView: $showNewWidgetView,  spaceId: spaceId, photoLinkedToProfile: $photoLinkedToProfile)
            
        })
        .toolbar(.hidden, for: .tabBar)
        
    }
    
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    }
}

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

let TILE_SIZE: CGFloat = 150
let MAX_ZOOM: CGFloat = 3.0
let MIN_ZOOM: CGFloat = 1
let CORNER_RADIUS: CGFloat = 15
let LINE_WIDTH: CGFloat = 2
let FRAME_SIZE: CGFloat = 1000

//HARDCODED SECTION


var imageView0 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .red, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!)
var imageView1 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .green, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://www.billboard.com/wp-content/uploads/2023/01/lisa-blackpink-dec-2022-billboard-1548.jpg?w=942&h=623&crop=1")!)

var imageView2 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .blue, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://i.mydramalist.com/66L5p_5c.jpg")!)
var imageView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .brown, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://static.wikia.nocookie.net/the_kpop_house/images/6/60/Jisoo.jpg/revision/latest?cb=20200330154248")!)

var videoView3 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE, borderColor: .orange, userId: "jisookim", media: .video, mediaURL: URL(string: "https://video.link/w/vl6552d3ab6cdff#")!)

var chatview = CanvasWidget(borderColor: .yellow, userId: "shenjjj", media: .chat, mediaURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)

var textView = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .green, userId: "jennierubyjane", media: .text, textString: "Gyatt")

var textView2 = CanvasWidget(width: TILE_SIZE, height: TILE_SIZE,borderColor: .green, userId: "jennierubyjane", media: .text, textString: "Unpopular opinion: NewJeans lowkeeeeeyyyy????? 👀👀")


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
    @State private var magnification: CGSize = CGSize(width: 1.0, height: 1.0);
    @State private var toolkit: PKToolPicker = PKToolPicker.init()
    
    
    
    private var spaceId: String
    
    
    @State private var newWidget: Bool = false
    @State private var widgetShake: Double = 0
    private var chatroomDocument: DocumentReference
    private var drawingDocument: DocumentReference
    
    enum canvasState {
        
        case drawing, normal
        
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
    
    func pushDrawing() {
        
    }
    
    func onChange() async {
        self.canvasWidgets = [textView, textView2, imageView0, imageView1, imageView2, imageView3, videoView3]
    }
    
    
    
    func GridView() -> AnyView {
        
        let columns = Array(repeating: GridItem(.fixed(TILE_SIZE), spacing: 50, alignment: .leading), count: 3)
        
        return AnyView(LazyVGrid(columns: columns, alignment: .leading, spacing: 50, content: {
            
            ForEach(canvasWidgets, id:\.id) { widget in
                
                getMediaView(widget: widget)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                    .overlay(
                        Text(widget.userId)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .offset(y:90)
                    )
                
                
                
                
                
                //                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
                //                        .stroke(widget.borderColor, lineWidth: LINE_WIDTH)
                //                        .frame(width: widget.width, height: widget.height)
                
                
                    .draggable(widget) {
                        
                        getMediaView(widget: widget)
                            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        
                            .onAppear{
                                draggingItem = widget
                            }
                        //
                    }
                
                    .dropDestination(for: CanvasWidget.self) { items, location in
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
                
            }
            
            
        }
                                 
                                 
                                 
                                ))
    }
    
    func canvasView() -> AnyView {
        
        return AnyView(
            ScrollView([.horizontal,.vertical], content: {
                ZStack {
                    GridView()
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE, alignment: .center)
                       
                        .border(Color.secondary, width: 1)
                    
                    DrawingCanvas(canvas: $canvas, toolPickerActive: $toolPickerActive, toolPicker: $toolkit)
                        .allowsHitTesting(toolPickerActive)
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                    
                    
                }
                .scaleEffect(magnification)
                
                
            })
       
            .scrollDisabled(currentMode != .normal)
            
            .gesture(magnify)
        )
    }
    
    var magnify: some Gesture {
        MagnificationGesture().onChanged { value in
            // Adjust sensitivity by multiplying the value
            let sensitivityMultiplier: CGFloat = 0.5 // Adjust this value as needed
            let adjustedValue = value * sensitivityMultiplier
            
            // Calculate new magnification
            let newMagnification = min(max(self.magnification.width * adjustedValue, MIN_ZOOM), MAX_ZOOM)
            self.magnification = CGSize(width: newMagnification, height: newMagnification)
        }
    }
    
    @Environment(\.undoManager) private var undoManager
    
    
    
    
    
    var body: some View {
        
        canvasView()
            .ignoresSafeArea()
            .task {
                await onChange()
            }
        //            .overlay(alignment: .top, content: {
        //                Toolbar().padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        //
        //            })
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
        
            .toolbar {
                
                //undo
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        undoManager?.undo()
                    }, label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                    })
                }
                //redo
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        undoManager?.redo()
                    }, label: {
                        Image(systemName: "arrow.uturn.forward.circle")
                    })
                }
                //pencilkit
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.toolPickerActive.toggle()
                        if toolPickerActive {
                            self.toolkit = PKToolPicker()
                            self.toolkit.addObserver(canvas)
                            canvas.becomeFirstResponder()
                        }
                        self.toolkit.setVisible(toolPickerActive, forFirstResponder: canvas)
                        if currentMode != .drawing {
                            self.currentMode = .drawing
                            self.activeGestures = .all
                        } else {
                            self.currentMode = .normal
                            self.activeGestures = .subviews
                        }
                    }, label: {
                        toolPickerActive
                        ? Image(systemName: "pencil.tip.crop.circle.fill")
                        : Image(systemName: "pencil.tip.crop.circle")
                    })
                }
                //add widget
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showNewWidgetView = true
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                }
                
            }
        
            .navigationBarTitleDisplayMode(.inline)
        //
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        
        
        
        //        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    }
}

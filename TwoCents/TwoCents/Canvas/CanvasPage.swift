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
let MIN_ZOOM: CGFloat = 0.6
let CORNER_RADIUS: CGFloat = 15
let FRAME_SIZE: CGFloat = 1000


func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}



struct CanvasPage: View {
    
    //var for widget onTap
    //@State var isShowingPopup = false
    
    @State private var userUID: String = ""
    @State var canvas: PKCanvasView = PKCanvasView()
    @State var toolPickerActive: Bool = false
    @State private var currentMode: canvasState = .normal
    @State private var canvasWidgets: [CanvasWidget] = []
    @State private var draggingItem: CanvasWidget?
    @State private var scrollPosition: CGPoint = CGPointZero
    @State private var activeGestures: GestureMask = .subviews
    @State private var showNewWidgetView: Bool = false
    @State private var photoLinkedToProfile: Bool = false
    @State private var widgetId: String = UUID().uuidString
    @State private var magnification: CGSize = CGSize(width: 1.0, height: 1.0);
    @State private var toolkit: PKToolPicker = PKToolPicker.init()
    @State private var pendingWrites: Bool = false
    @State private var timer: Timer?
    
    @State private var selectedWidget: CanvasWidget?
 
    @StateObject private var viewModel = CanvasPageViewModel()
    
    
    private var spaceId: String
    
    
    @State private var widgetDoubleTapped: Bool = false
    
    
    private var chatroomDocument: DocumentReference
    private var drawingDocument: DocumentReference

    enum canvasState {
        
        case drawing, normal
        
    }
    
    init(spaceId: String) {
        self.spaceId = spaceId
        
        self.chatroomDocument = db.collection("spaces").document(spaceId)
        self.drawingDocument = db.collection("spaces").document(spaceId).collection("Widgets").document("Drawings")
        
    }
    
    
    
    func pullDocuments() async {
        db.collection("spaces").document(spaceId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard document.exists else {
                print("Document doesn't exist")
                return
            }
            
            guard let data = document.data() else {
                print("Empty document")
                return
            }
            
            //@TODO: Add checks for what writes type it is
            if let drawingAccess = data["drawing"] as? Data {
                let databaseDrawing = try! PKDrawingReference(data: drawingAccess)
                let newDrawing = databaseDrawing.appending(self.canvas.drawing)
                self.canvas.drawing = newDrawing
            } else {
                print("No database drawing")
            }
        }
        
        db.collection("spaces").document(spaceId).collection("widgets").addSnapshotListener { querySnapshot, error in
            guard let query = querySnapshot else {
                print("Error fetching query: \(error!)")
                return
            }
            self.canvasWidgets = []
            for document in query.documents {
                let newWidget = try! document.data(as: CanvasWidget.self)
                self.canvasWidgets.append(newWidget)
            }
        }
    }
    
    func onChange() async {
        await pullDocuments()
    }
    
    
    
    
    func GridView() -> AnyView {
        @State var isShowingPopup = false
        let columns = Array(repeating: GridItem(.fixed(TILE_SIZE), spacing: 30, alignment: .center), count: 3)

        return AnyView(LazyVGrid(columns: columns, alignment: .center, spacing: 30, content: {
            
            ForEach(canvasWidgets, id:\.id) { widget in
                //main widget
                getMediaView(widget: widget, spaceId: spaceId)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                    
                //clickable area/outline when clicked
                    .overlay(
                        RoundedRectangle(cornerRadius: CORNER_RADIUS)
                            .strokeBorder(selectedWidget == widget ? Color.secondary : .clear, lineWidth: 2)
                            .contentShape(RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .cornerRadius(CORNER_RADIUS)
                        
                            .onTapGesture(count: 2, perform: {
                                
                                if selectedWidget != widget || !widgetDoubleTapped {
                                    //select
                                    selectedWidget = widget
                                    widgetDoubleTapped = true
                                    
                                } else {
                                    //deselect
                                    selectedWidget = nil
                                    widgetDoubleTapped = false
                                }
                            })
                    )
                
                //username below widget
                    .overlay(content: {
                        
                        Text(widgetDoubleTapped ? widget.userId : ""  )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .offset(y:90)
                    })
                    .blur(radius: widgetDoubleTapped && selectedWidget != widget ? 20 : 0)
                    .scaleEffect(widgetDoubleTapped && selectedWidget == widget ? 1.05 : 1)
                //emoji react
                    .overlay( alignment: .top, content: {
                        if widgetDoubleTapped && selectedWidget == widget {
                            EmojiReactionsView(spaceId: spaceId, widget: widget)
                                .offset(y:-60)
                        }
                    })
                    .draggable(widget) {
                        getMediaView(widget: widget, spaceId: spaceId)
                            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .scaleEffect(zoomValue + 1)
                            .onAppear{
                                draggingItem = widget
                            }
                    }
                //where its dropped
                    .dropDestination(for: CanvasWidget.self) { items, location in
                        draggingItem = nil
                        return false
                    } isTargeted: { status in
                        if let draggingItem, status, draggingItem != widget {
                            if let sourceIndex = canvasWidgets.firstIndex(of: draggingItem),
                               let destinationIndex = canvasWidgets.firstIndex(of: widget) {
                                withAnimation(.bouncy) {
                                    //move widget
                                    let sourceItem = canvasWidgets.remove(at: sourceIndex)
                                    canvasWidgets.insert(sourceItem, at: destinationIndex)
                                    //deselect
                                    selectedWidget = nil
                                    widgetDoubleTapped = false
                                    
                                }
                            }
                        }
                    }
            }
            
        }
      
                                )
        )
    }
    @State var zoomValue: CGFloat = 0
    
    func canvasView() -> AnyView {
        
        return AnyView(
            
            ScrollView([.horizontal,.vertical], content: {
                ZStack {
          
                    Color(UIColor.systemBackground)
                             .allowsHitTesting(toolPickerActive)
                    GridView()
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE, alignment: .center)
//                        .border(Color.secondary, width: 1)
                    
                      
                    DrawingCanvas(canvas: $canvas, toolPickerActive: $toolPickerActive, toolPicker: $toolkit, spaceId: spaceId)
                        .allowsHitTesting(toolPickerActive)
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                    
                }
                
//                .scaleEffect(magnification)
                
                .scaleEffect(zoomValue + 1)
            }
                
              
                
                      )
            
            
            .gesture(
                MagnificationGesture()
                    .onChanged{value in
                        print(value)
                        
                      
                        zoomValue = value - 1
                    }
//                        .onEnded({ value in
//                            withAnimation(.spring()) {
//                                currentAmount = 0
//                            }
//                        })
            )
            .onTapGesture {
             //deselect
                    selectedWidget = nil
                widgetDoubleTapped = false
            }
            .scrollDisabled(currentMode != .normal)
//            .gesture(magnify)
            //hovering action menu when widget is clicked
            .overlay(selectedWidget != nil
                     ? HStack{
                         Button(action: {
                             if let selectedWidget, let index = canvasWidgets.firstIndex(of: selectedWidget){
                                 canvasWidgets.remove(at: index)
                                 SpaceManager.shared.removeWidget(spaceId: spaceId, widget: selectedWidget)
                             }
                             selectedWidget = nil
                             widgetDoubleTapped = false
                           
                         }, label: {
                             Image(systemName: "trash")
                                 .foregroundColor(.red)
                         })
                     }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemBackground), in: .capsule)
                        .contentShape(.capsule)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 2)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 50)
                     :  nil
                    )
                    .animation(.easeInOut)
                    .background( Color(UIColor.secondarySystemBackground))
           
        )
    }
    
    private func removeExpiredStrokes() {
        var changed: Bool = false
        let strokes = canvas.drawing.strokes.filter { stroke in
            if (stroke.isExpired()) {
                changed = true
            }
            return !stroke.isExpired()
        }
        if changed {
    
                canvas.drawing = PKDrawing(strokes: strokes)
                canvas.upload(spaceId: spaceId)
            
           
        }
    }
//    
//    var magnify: some Gesture {
//        MagnificationGesture().onChanged { value in
//            // Adjust sensitivity by multiplying the value
//            let sensitivityMultiplier: CGFloat = 0.5 // Adjust this value as needed
//            let adjustedValue = value * sensitivityMultiplier
//            
//            // Calculate new magnification
//            let newMagnification = min(max(self.magnification.width * adjustedValue, MIN_ZOOM), MAX_ZOOM)
//            self.magnification = CGSize(width: newMagnification, height: newMagnification)
//         
//        }
//    }
    
    @Environment(\.undoManager) private var undoManager
    
    var body: some View {
        canvasView()
            .ignoresSafeArea()
            .task {
                await onChange()
            }
        //add new widget view
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
            .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
       
                removeExpiredStrokes()
            }
        //toolbar
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                if toolPickerActive{
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
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task{
                try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            }
            .navigationTitle(toolPickerActive ? "" : viewModel.space?.name ?? "" )
    }
       
    
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    }
}

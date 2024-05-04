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
    @Environment(\.presentationMode) var presentationMode
    //var for widget onTap
    //@State var isShowingPopup = false
    
    @State private var username: String = ""
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
    //    @Environment(\.dismiss) var dismissScreen
    
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
                                Task {
                                    username = try! await UserManager.shared.getUser(userId: widget.userId).username!
                                }
                            })
                    )
                
                //username below widget
                    .overlay(content: {
                        Text(widgetDoubleTapped ? username : "" )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .offset(y:90)
                    })
                    .blur(radius: widgetDoubleTapped && selectedWidget != widget ? 20 : 0)
                    .scaleEffect(widgetDoubleTapped && selectedWidget == widget ? 1.05 : 1)
                //emoji react MENU
                    .overlay( alignment: .top, content: {
                        if widgetDoubleTapped && selectedWidget == widget {
                            EmojiReactionsView(spaceId: spaceId, widget: widget)
                                .offset(y:-60)
                            
                        }
                    })
                //list of what users reacted with
                //                    .overlay( alignment: .top, content: {
                //                        if widgetDoubleTapped && selectedWidget == widget {
                //                            EmojiCountView(spaceId: spaceId, widget: widget)
                //
                //                                .offset(y:140)
                //                        }
                //                    })
                    .draggable(widget) {
                        
                        VStack{
                            getMediaView(widget: widget, spaceId: spaceId)
                                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            
                            
                            //                                .scaleEffect(scale)
                            
                                .frame(
                                    width: TILE_SIZE,
                                    height: TILE_SIZE
                                )
                                .scaleEffect(scale)
                                .frame(
                                    width: TILE_SIZE * scale,
                                    height: TILE_SIZE * scale
                                )
                            
                            
                                .onAppear{
                                    draggingItem = widget
                                    
                                    
                                }
                            
                            
                            
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
    //    @State var zoomValue: CGFloat = -0.1
    @State var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    
    func canvasView() -> AnyView {
        
        return AnyView(
            
            ScrollView([.horizontal,.vertical], content: {
                ZStack {
                    
                    Color(UIColor.systemBackground)
                        .allowsHitTesting(toolPickerActive)
                    
                    GeometryReader { geometry in
                        Path { path in
                            let spacing: CGFloat = 30 // Adjust this value for the spacing between dots
                            let width = geometry.size.width
                            let height = geometry.size.height
                            
                            for x in stride(from: 0, through: width, by: spacing) {
                                for y in stride(from: 0, through: height, by: spacing) {
                                    path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
                                }
                            }
                        }
                        .fill(Color(UIColor.secondaryLabel)) // Dot color
                        .allowsHitTesting(toolPickerActive)
                    }
                    .drawingGroup()
                    .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                    .blur(radius: widgetDoubleTapped ? 3 : 0)
                    
                    
                    GridView()
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                    
                    
                    
                    
                    DrawingCanvas(canvas: $canvas, toolPickerActive: $toolPickerActive, toolPicker: $toolkit, spaceId: spaceId)
                        .allowsHitTesting(toolPickerActive)
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                    
                }
                
                .frame(
                    width: FRAME_SIZE,
                    height: FRAME_SIZE
                )
                
                .scaleEffect(scale)
                .frame(
                    width: FRAME_SIZE * 2,
                    height: FRAME_SIZE * 2
                )
                
//                .frame(
//                    width: FRAME_SIZE * scale,
//                    height: FRAME_SIZE * scale
//                )
//                
//
                
            }
                      )
            .contentShape(Rectangle())
            .defaultScrollAnchor(.center)
            
            .gesture(
                MagnificationGesture()
                    .onChanged { val in
                        let delta = val / self.lastScaleValue
                        self.lastScaleValue = val
                        let newScale = self.scale * delta
                        self.scale = min(max(newScale, 0.1), 2)
                        
                        
                    }.onEnded { val in
                        self.lastScaleValue = 1.0
                    }
            )
            .onTapGesture {
                //deselect
                selectedWidget = nil
                widgetDoubleTapped = false
            }
                .scrollDisabled(currentMode != .normal)
            //hovering action menu when widget is clicked
                .overlay(selectedWidget != nil
                         ? VStack {
                             EmojiCountView(spaceId: spaceId, widget: selectedWidget!)
                                 .padding(.top, 120)
                             Spacer()
                             HStack{
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
                         }
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
                
                
                
                //SPACE SETTINGS
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SpaceSettingsView(spaceId: spaceId)
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    
                }
                
                
                
                
                
                
            }
            .navigationBarTitleDisplayMode(.inline)
        //            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        //SHOW BACKGROUND BY CHANGING BELOW TO VISIBLE
            .toolbarBackground(.hidden, for: .navigationBar)
            .task{
                
                
                do {
                    try await viewModel.loadCurrentSpace(spaceId: spaceId)
                } catch {
                    //EXIT IF SPACE DOES NOT EXIST
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                if let userInSpace = try? await viewModel.space?.members?.contains(getUID() ?? ""){
                    print(userInSpace)
                    if !userInSpace {
                        
                        //if user not in space, exit
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }
                }
            }
            .navigationTitle(toolPickerActive ? "" : viewModel.space?.name ?? "" )
    }
    
    
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    }
}

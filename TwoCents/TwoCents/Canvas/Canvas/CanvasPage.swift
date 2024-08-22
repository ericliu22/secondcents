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
let TILE_SPACING: CGFloat = 30
let MAX_ZOOM: CGFloat = 3.0
let MIN_ZOOM: CGFloat = 0.6
let CORNER_RADIUS: CGFloat = 15
let FRAME_SIZE: CGFloat = 2000
let WIDGET_SPACING: CGFloat = TILE_SIZE + TILE_SPACING





struct CanvasPage: View {
    @Environment(\.presentationMode) var presentationMode
    //var for widget onTap
    //@State var isShowingPopup = false
    
    @State private var fullName: String = ""
    @State var canvas: PKCanvasView = PKCanvasView()
    @State var toolPickerActive: Bool = false
    @State private var currentMode: canvasState = .normal
    @State private var canvasWidgets: [CanvasWidget] = []
    @State private var draggingItem: CanvasWidget?
    @State private var inSettingsView: Bool = false
    @State private var photoLinkedToProfile: Bool = false
    @State private var widgetId: String = UUID().uuidString
    @State private var toolkit: PKToolPicker = PKToolPicker()
    @State private var pendingWrites: Bool = false
    @State private var timer: Timer?

    @State private var activeSheet: sheetTypesCanvasPage?
    @State private var activeWidget: CanvasWidget?
    @State private var replyWidget: CanvasWidget?
    @State private var selectedDetent: PresentationDetent = .height(50)
    
    
    @StateObject private var viewModel = CanvasPageViewModel()
    @Environment(AppModel.self) var appModel
    
    private var spaceId: String
    
    
    
    //helps reset view
    @State private var refreshId = UUID()
    
    
    
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
    
    
    
    func pullDocuments() {
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
    
    
    //For some reason this has to be async or else shit doesn't work
    func onChange() async {
        print("ran on change")
        pullDocuments()
    }
    

    
    func Background() -> some View {
                GeometryReader { geometry in
                    Path { path in
                        let spacing: CGFloat = TILE_SPACING // Adjust this value for the spacing between dots
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        for x in stride(from: 4, through: width, by: spacing) {
                            for y in stride(from: 4, through: height, by: spacing) {
                                path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
                            }
                        }
                    }
                    .fill(Color(UIColor.secondaryLabel)) // Dot color
                    .allowsHitTesting(toolPickerActive)
                }
                .drawingGroup()
              
                .clipped() // Ensure the content does not overflow
                //                    .animation(.spring()) // Optional: Add some animation
                .frame(width: FRAME_SIZE, height: FRAME_SIZE)

    }
    

    

    func canvasView() -> some View {
            ZStack {
                
//                                     
                Color("bgColor")
                .clipped()
                .frame(width: FRAME_SIZE, height: FRAME_SIZE)

                Background()
                GridView()
            }
            .dropDestination(for: CanvasWidget.self) { receivedWidgets, location in
                //This is necessary keep these lines
                
                if draggingItem != nil {
                    let x = roundToTile(number: location.x)
                    let y = roundToTile(number: location.y)

                    SpaceManager.shared.moveWidget(spaceId: spaceId, widgetId: draggingItem!.id.uuidString, x: x, y: y)
                    draggingItem = nil
                    return true
                } else {
                    return false
                }
            }
   
                .overlay(
                    DrawingCanvas(canvas: $canvas, toolPickerActive: $toolPickerActive, toolPicker: $toolkit, spaceId: spaceId)
                        .allowsHitTesting(toolPickerActive)
                        .clipped() // Ensure the content does not overflow
                        .animation(.spring()) // Optional: Add some animation
                        .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                    
                )
      
    }
    
    private func removeExpiredStrokes() {
        var changed: Bool = false
        let strokes = canvas.drawing.strokes.filter { stroke in
            if (stroke.isExpired()) {
                changed = true
            }
            //include only if not expired
            return !stroke.isExpired()
        }
        if changed {
            
            canvas.drawing = PKDrawing(strokes: strokes)
            canvas.upload(spaceId: spaceId)
            
            
        }
    }
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
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
            }, label: {
                toolPickerActive
                ? Image(systemName: "pencil.tip.crop.circle.fill")
                : Image(systemName: "pencil.tip.crop.circle")
            })
        }
        //add widget
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                activeSheet = .newWidgetView
                
            }, label: {
                Image(systemName: "plus.circle")
            })
        }
        
        //SPACE SETTINGS
        ToolbarItem(placement: .topBarTrailing) {
            
            NavigationLink {
                
                SpaceSettingsView(spaceId: spaceId)
                    .onAppear {
                        activeSheet = nil
                        inSettingsView = true
                    }
                    .onDisappear {
                        activeSheet = .chat
                        inSettingsView = false
                    }
            } label: {
                Image(systemName: "ellipsis")
                
            }
        }
    }
    
    
     func GridView() -> some View {
            ForEach(canvasWidgets, id:\.id) { widget in
                //main widget
                MediaView(widget: widget, spaceId: spaceId, activeSheet: $activeSheet, activeWidget: $activeWidget)
                    .contextMenu(ContextMenu(menuItems: {
                        
                        EmojiReactionContextView(spaceId: spaceId, widget: widget, refreshId: $refreshId)
                        
                        
                        
                        
                        widgetButton(widget: widget)
                         
                        
                        // Reply button
                        Button(action: {
                            
                        
                            activeSheet = .chat
                            selectedDetent = .large
                            replyWidget = widget
                        }, label: {
                            
                            Label("Reply", systemImage: "arrowshape.turn.up.left")
//                            Image(systemName: "arrowshape.turn.up.left")
                              
                        })
                        
                        
                        
                        // Delete button
                  
                        
                        Button(role: .destructive) {
                            if let index = canvasWidgets.firstIndex(of: widget)  {
                                canvasWidgets.remove(at: index)
                                SpaceManager.shared.removeWidget(spaceId: spaceId, widget: widget)
                                
                                //delete specific widget items (in their own folders)
                                
                                switch widget.media {
                                    
                                case .poll:
                                    deletePoll(spaceId: spaceId, pollId: widget.id.uuidString)
                                case .todo:
                                    deleteTodoList(spaceId: spaceId, todoId: widget.id.uuidString)
                                
                                case .calendar:
                                    deleteCalendar(spaceId: spaceId, calendarId: widget.id.uuidString)
                                default:
                                    break
                                    
                                }
                           
                            }
                        
                            activeSheet = .chat
                        } label: {
                            
                            Label("Delete", systemImage: "trash")
                          
                        }

                        
                        
                        

                    }))

                
                
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                    .frame(
                        width: TILE_SIZE,
                        height: TILE_SIZE
                    )
                    .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                    
                   
                    .draggable(widget) {
                        MediaView(widget: widget, spaceId: spaceId, activeSheet: $activeSheet, activeWidget: $activeWidget)
                            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .frame(
                                width: TILE_SIZE,
                                height: TILE_SIZE
                            )
                            .onAppear{
                                draggingItem = widget
                            }
                    }
                
            }
    }
    
  

    
    func widgetButton( widget: CanvasWidget) -> some View {
        switch widget.media {
        case .poll:
            return Button(action: {
                activeWidget = widget
                activeSheet =  .poll
            }, label: {
                Label("Open Poll", systemImage: "list.clipboard")
            }).eraseToAnyView()
            
            
        case .todo:
            return Button(action: {
                activeWidget = widget
                activeSheet = .todo
            }, label: {
                
                Label("Open List", systemImage: "checklist")
            }).eraseToAnyView()

        case .map:
            return Button(action: {
                if let location = widget.location {
                    viewModel.openMapsApp(location: location)
                }
            }, label: {
                
                Label("Open Map", systemImage: "mappin.and.ellipse")
            }).eraseToAnyView()
        case .link:
            return Button(action:{
                if let url = widget.mediaURL {
                    viewModel.openLink(url: url)
                }
            }, label: {
                
                Label("Open Link", systemImage: "link")
            }).eraseToAnyView()
            
            
        case .image:
            return Button(action: {
                activeWidget = widget
                activeSheet = .image
            }, label: {
                
                Label("Open Image", systemImage: "photo")
            }).eraseToAnyView()

            
            
            
        case .video:
            return Button(action: {
                activeWidget = widget
                activeSheet = .video
            }, label: {
                
                Label("Open Video", systemImage: "video")
            }).eraseToAnyView()

            
        case .calendar:
            return Button(action: {
                activeWidget = widget
                activeSheet = .calendar
            }, label: {

                
                Label("Select Availability", systemImage: "calendar")
            }).eraseToAnyView()
            
            
        default:
            return EmptyView().eraseToAnyView()
        }
    }
    
  
    
    @Environment(\.undoManager) private var undoManager
    var body: some View {
        ZoomableScrollView(toolPickerActive: $toolPickerActive) {
            canvasView()
                .frame(width: FRAME_SIZE * 1.5, height: FRAME_SIZE * 1.5)
                .ignoresSafeArea()
                .task {
                    await onChange()
                }
            //add new widget view and ChatSHEET
               
                .onAppear(perform: {
                    activeSheet = .chat
                })
                .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
                    
                    removeExpiredStrokes()
                }
            //toolbar
                .toolbar(.hidden, for: .tabBar)
                .toolbar {toolbar()}
                .navigationBarTitleDisplayMode(.inline)
            //SHOW BACKGROUND BY CHANGING BELOW TO VISIBLE
                .toolbarBackground(.hidden, for: .navigationBar)
                .task{
                    
                    
                    do {
                        try await viewModel.loadCurrentSpace(spaceId: spaceId)
                        print("Done with loadCurrentSpace")
                        appModel.currentSpaceId = spaceId
                        appModel.inSpace = true

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
//                .background(  Color(UIColor.secondarySystemBackground))
                .background(Color(UIColor.secondarySystemBackground))
        }
        .onChange(of: appModel.shouldNavigateToSpace, {
            if appModel.shouldNavigateToSpace {
                if (appModel.navigationSpaceId != spaceId) {
                    print("CANVASPAGE DISMISSING")
                    presentationMode.wrappedValue.dismiss()
                    appModel.inSpace = false
                }
                //Wait is necessary because sometimes this shit happens too fast and threads aren't waiting yet
                //There is a rare bug where the other threads happen way too slow this guy already ends
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    appModel.mutex.broadcast()
                    print("signaled")
                }
            }
        })
        .ignoresSafeArea()
        .sheet(item: $activeSheet, onDismiss: {
            
            replyWidget = nil
            activeWidget = nil
            
        
            
            //get chat to show up at all times
            if !inSettingsView && activeSheet == nil{
                inSettingsView = false
                activeSheet = .chat
                selectedDetent = .height(50)
            }
            
            
            if photoLinkedToProfile {
                photoLinkedToProfile = false
                widgetId = UUID().uuidString
            } else {
                Task{
                    try await StorageManager.shared.deleteTempWidgetPic(spaceId:spaceId, widgetId: widgetId)
                }
            }
            
        }, content: { item in
            
            switch item {
            case .newWidgetView:
                NewWidgetView(widgetId: widgetId,   spaceId: spaceId, photoLinkedToProfile: $photoLinkedToProfile)
//                            .presentationBackground(Color(UIColor.systemBackground))
                    .presentationBackground(.thickMaterial)
            case .chat:

                
                NewChatView(spaceId: spaceId, replyWidget: $replyWidget, detent: $selectedDetent,activeSheet: $activeSheet, activeWidget: $activeWidget)
                
                    .presentationBackground(Color(UIColor.systemBackground))
                    .presentationDetents([.height(50),.large], selection: $selectedDetent)
                
                
                    .presentationCornerRadius(20)
                
                    .presentationBackgroundInteraction(.enabled)
                    .onChange(of: selectedDetent) {
                        if selectedDetent != .large {
                            
                            withAnimation {
                                replyWidget = nil
                               
                            }
                            
                            print("detent is 50")
                        }
                    }
                
                
            case .poll:
                
                //Waits until activeWidget is not nil
                PollWidgetSheetView(widget: waitForVariable{activeWidget}, spaceId: spaceId)
                
            case .newTextView:
                NewTextWidgetView(spaceId: spaceId)
                    .presentationBackground(Color(UIColor.systemBackground))
            case .todo:
                    //Waits until activeWidget is not nil
                    TodoWidgetSheetView(widget: waitForVariable{activeWidget}, spaceId: spaceId)
                    .presentationBackground(Color(UIColor.systemBackground))
            case .image:
                    ImageWidgetSheetView(widget: waitForVariable{activeWidget}, spaceId: spaceId)
                    .presentationBackground(.thickMaterial)
              
                
                  
            case .video:
                VideoWidgetSheetView(widget: waitForVariable{activeWidget}, spaceId: spaceId)
                .presentationBackground(.thickMaterial)
            case .calendar:
                
                CalendarWidgetSheetView(spaceId: spaceId, widgetId:  waitForVariable{activeWidget?.id.uuidString})
                .presentationBackground(.thickMaterial)
            }
            
        })

        .onDisappear(perform: {
            activeSheet = nil            
            appModel.inSpace = false
            appModel.currentSpaceId = nil
            print("CANVASPAGE DISAPPEARED")
            print("CANVASPAGE: appModel.inSpace \(appModel.inSpace)")

        })
        .background(  Color(UIColor.secondarySystemBackground))
        
    }
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"87D5AC3A-24D8-4B23-BCC7-E268DBBB036F")
    }
}


extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

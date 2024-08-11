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

func roundToTile(number : CGFloat) -> CGFloat {
    let tile = WIDGET_SPACING
    return tile * CGFloat(Int(round(number / (tile))))
}

func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}



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
    
    
    @State private var widgetDoubleTapped: Bool = false
    //    @Environment(\.dismiss) var dismissScreen
    
    private var chatroomDocument: DocumentReference
    private var drawingDocument: DocumentReference
    
    enum canvasState {
        case drawing, normal
    }
    
    
    enum sheetTypesCanvasPage: Identifiable  {
        case newWidgetView, chat, poll, newTextView, todo
        
        var id: Self {
            return self
        }
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
                //                    .frame(width: FRAME_SIZE, height: FRAME_SIZE)
                .blur(radius: widgetDoubleTapped ? 3 : 0)
                .clipped() // Ensure the content does not overflow
                //                    .animation(.spring()) // Optional: Add some animation
                .frame(width: FRAME_SIZE, height: FRAME_SIZE)

    }
    

    

    func canvasView() -> some View {
            ZStack {
                
                                     
                Color(UIColor.systemBackground)
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
   
                .onTapGesture(count: 2, perform: {
                    activeSheet = .newTextView
                })
            
                .onTapGesture {
                    //deselect
                    if (viewModel.selectedWidget != nil) { 
                    viewModel.selectedWidget = nil
                    widgetDoubleTapped = false
                    activeSheet = .chat
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
                
                
                //                        showSheet = true
                //                        showNewWidgetView = true
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
            //            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
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
                .background(  Color(UIColor.secondarySystemBackground))
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
            //                showNewWidgetView = false
            //                            activeSheet = .chat
            
          
            replyWidget = nil
            activeWidget = nil
            
            //get chat to show up at all times
            if !widgetDoubleTapped && !inSettingsView && activeSheet == nil{
                //                                showSheet = true
                inSettingsView = false
                activeSheet = .chat
                
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
//                ChatView(spaceId: spaceId,replyMode: $replyMode, replyWidget: $replyWidget, selectedDetent: $selectedDetent)
                
                NewChatView(spaceId: spaceId, replyWidget: $replyWidget, detent: $selectedDetent)
                
                    .presentationBackground(Color(UIColor.systemBackground))
                    .presentationDetents([.height(50),.large], selection: $selectedDetent)
                
                
                    .presentationCornerRadius(20)
                
                    .presentationBackgroundInteraction(.enabled)
                    .onChange(of: selectedDetent) { selectedDetent in
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
        .overlay(doubleTapOverlay())
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

//This resolves single tap issue
//Forces things to wait until variable is not nil

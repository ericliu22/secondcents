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
    @State private var inSettingsView: Bool = false
    @State private var photoLinkedToProfile: Bool = false
    @State private var widgetId: String = UUID().uuidString
    @State private var toolkit: PKToolPicker = PKToolPicker()
    @State private var pendingWrites: Bool = false
    @State private var timer: Timer?
    @State private var replyMode: Bool = false
    @State private var activeSheet: sheetTypesCanvasPage?
    @State private var activePollWidget: CanvasWidget?
    @State private var replyWidget: CanvasWidget?
    @State private var selectedDetent: PresentationDetent = .height(50)
    
    
    
    
    
    @StateObject private var viewModel = CanvasPageViewModel()
    
    
    private var spaceId: String
    
    
    @State private var widgetDoubleTapped: Bool = false
    //    @Environment(\.dismiss) var dismissScreen
    
    private var chatroomDocument: DocumentReference
    private var drawingDocument: DocumentReference
    
    enum canvasState {
        case drawing, normal
    }
    
    
    enum sheetTypesCanvasPage: Identifiable  {
        case newWidgetView, chat, poll, newTextView
        
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
    
    func GridView() -> some View {
        let columns = Array(repeating: GridItem(.fixed(TILE_SIZE), spacing: 30, alignment: .center), count: 5)
        
        return LazyVGrid(columns: columns, alignment: .center, spacing: 30, content: {
            
            ForEach(canvasWidgets, id:\.id) { widget in
                //main widget
                MediaView(widget: widget, spaceId: spaceId)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                    .cornerRadius(CORNER_RADIUS)
                
                  
                 
                
                //clickable area/outline when clicked
                    .overlay(
                        RoundedRectangle(cornerRadius: CORNER_RADIUS)
                            .strokeBorder(viewModel.selectedWidget == widget ? Color.secondary : .clear, lineWidth: 3)
                            .contentShape(RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            .cornerRadius(CORNER_RADIUS)
                        
                            .onTapGesture(count: 2, perform: {
                                if viewModel.selectedWidget != widget || !widgetDoubleTapped {
                                    //select
                                    
                                    viewModel.selectedWidget = widget
                                    widgetDoubleTapped = true
                                    //                                    showSheet = false
                                    //                                    showNewWidgetView = false
                                    activeSheet = nil
                                    
                                } else {
                                    //deselect
                                    viewModel.selectedWidget = nil
                                    widgetDoubleTapped = false
                                    //                                    showSheet = true
                                    //                                    showNewWidgetView = false
                                    activeSheet = .chat
                                }
                                Task {
//                                    username = try? await UserManager.shared.getUser(userId: widget.userId).username
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
                    .blur(radius: widgetDoubleTapped && viewModel.selectedWidget != widget ? 20 : 0)
                    .scaleEffect(widgetDoubleTapped && viewModel.selectedWidget == widget ? 1.05 : 1)
                    .animation(.spring)
                    //emoji react MENU
                    .overlay( alignment: .top, content: {
                        if widgetDoubleTapped && viewModel.selectedWidget == widget {
                            EmojiReactionsView(spaceId: spaceId, widget: widget)
                                .offset(y:-60)
                            
                        }
                    })
                
                    .overlay(content: {
                        
                        
                        viewModel.selectedWidget == nil/* && draggingItem == nil */?
                        EmojiCountOverlayView(spaceId: spaceId, widget: widget)
                            .offset(y: TILE_SIZE/2)
                        : nil
                        
                        
                    })
                
                    .draggable(widget) {
                        
                        VStack{
                            MediaView(widget: widget, spaceId: spaceId)
                                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                            
                            //a bad way of resizing the draggable items but oh well
                                .frame(
                                    width: TILE_SIZE,
                                    height: TILE_SIZE
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
                                //                                withAnimation(.bouncy) {
                                //move widget
                                let sourceItem = canvasWidgets.remove(at: sourceIndex)
                                canvasWidgets.insert(sourceItem, at: destinationIndex)
                                
                                
                                
                                //deselect
                                viewModel.selectedWidget = nil
                                widgetDoubleTapped = false
                                
                                //                                showSheet = true
                                //                                showNewWidgetView = false
                                activeSheet = .chat
                                
                                //                                }
                            }
                        }
                        
                        //added this line for emoji overlay... if it breaks delete this
                        //                        draggingItem = nil
                    }
                
            }
            
        }
                                 
                                )
    }
    
    func Background() -> some View {
                GeometryReader { geometry in
                    Path { path in
                        let spacing: CGFloat = 30 // Adjust this value for the spacing between dots
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
    func doubleTapOverlay() -> some View {
        viewModel.selectedWidget != nil ? VStack {
            EmojiCountHeaderView(spaceId: spaceId, widget: viewModel.selectedWidget!)
            Spacer()
            HStack(spacing: 5) { // Increase spacing between buttons
                // Map button
                if viewModel.selectedWidget!.media == .map {
                    Button(action: {
                        if let location = viewModel.selectedWidget?.location {
                            viewModel.openMapsApp(location: location)
                        }
                        viewModel.selectedWidget = nil
                        widgetDoubleTapped = false
                    }, label: {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Color(UIColor.label))
                            .padding(.horizontal, 5)
                    })
//                    .contentShape(Rectangle())
                }

                // Poll button
                if viewModel.selectedWidget!.media == .poll {
                    Button(action: {
                        activePollWidget = viewModel.selectedWidget
                        viewModel.selectedWidget = nil
                        widgetDoubleTapped = false
                        activeSheet = .poll
                    }, label: {
                        Image(systemName: "checklist")
                            .foregroundColor(Color(UIColor.label))
                            .font(.title3)
                            .padding(.horizontal, 5)
                    })
//                    .contentShape(Rectangle())
                }

                // Reply button
                Button(action: {
                    replyMode = true
                    replyWidget = viewModel.selectedWidget
                    viewModel.selectedWidget = nil
                    widgetDoubleTapped = false
                    activeSheet = .chat
                }, label: {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundColor(Color(UIColor.label))
                        .font(.title3)
                        .padding(.horizontal, 5)
                })
//                .contentShape(Rectangle())

                // Delete button
                Button(action: {
                    if let selectedWidget = viewModel.selectedWidget, let index = canvasWidgets.firstIndex(of: selectedWidget)  {
                        canvasWidgets.remove(at: index)
                        SpaceManager.shared.removeWidget(spaceId: spaceId, widget: selectedWidget)
                        if selectedWidget.media == .poll {
                            deletePoll(spaceId: spaceId, pollId: selectedWidget.id.uuidString)
                        }
                    }
                    viewModel.selectedWidget = nil
                    widgetDoubleTapped = false
                    activeSheet = .chat
                }, label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                        .padding(.horizontal, 5) // Increase padding
                     
                })
//                .contentShape(Rectangle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10) // Add vertical padding
            .background(Color(UIColor.systemBackground), in: Capsule())
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 4)
        }
        
        .frame(maxHeight: .infinity, alignment: .bottom)
        : nil
    }

    

    func canvasView() -> some View {
            ZStack {
//                                        Color(UIColor.secondarySystemBackground)
                Color(UIColor.systemBackground)
                //                        .scaleEffect(scale)
                //                            .scaleEffect(scale,
                    .clipped() // Ensure the content does not overflow
                //                        .animation(.spring()) // Optional: Add some animation
                    .frame(width: FRAME_SIZE, height: FRAME_SIZE)

                Background()
                GridView()
                //                    .clipped() // Ensure the content does not overflow
                //                    .animation(.spring()) // Optional: Add some animation
                
            }
                
                .onTapGesture(count: 2, perform: {
                    
                    activeSheet = .newTextView
                })
            
                .onTapGesture {
                    //deselect
                    viewModel.selectedWidget = nil
                    widgetDoubleTapped = false
                    activeSheet = .chat
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
            return !stroke.isExpired()
        }
        if changed {
            
            canvas.drawing = PKDrawing(strokes: strokes)
            canvas.upload(spaceId: spaceId)
            
            
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
                .navigationBarTitleDisplayMode(.inline)
            //            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            //SHOW BACKGROUND BY CHANGING BELOW TO VISIBLE
                .toolbarBackground(.hidden, for: .navigationBar)
                .task{
                    
                    
                    do {
                        try await viewModel.loadCurrentSpace(spaceId: spaceId)
                        print("Done with loadCurrentSpace")
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
        .ignoresSafeArea()
        .sheet(item: $activeSheet, onDismiss: {
            //                showNewWidgetView = false
            //                            activeSheet = .chat
            
            replyMode = false
            replyWidget = nil
            
            activePollWidget = nil
            
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
                ChatView(spaceId: spaceId,replyMode: $replyMode, replyWidget: $replyWidget, selectedDetent: $selectedDetent)
                
                
                
                
                    .presentationBackground(Color(UIColor.systemBackground))
                
                    .presentationDetents([.height(50),.medium], selection: $selectedDetent)
                
                
                    .presentationCornerRadius(20)
                
                    .presentationBackgroundInteraction(.enabled)
                    .onChange(of: selectedDetent) { selectedDetent in
                        if selectedDetent != .medium && replyMode {
                            
                            withAnimation {
                                replyWidget = nil
                                replyMode = false
                            }
                            
                            
                            print("detent is 50")
                        }
                    }
                
                
            case .poll:
                
                
                
                if let widget = activePollWidget {
                    PollWidgetSheetView(widget: widget, spaceId: spaceId)
                } else {
                    ProgressView()
                        .foregroundStyle(Color(UIColor.label))
                        .presentationBackground(Color(UIColor.systemBackground))
                    
                }
                
            case .newTextView:
                NewTextWidgetView(spaceId: spaceId)
                    .presentationBackground(Color(UIColor.systemBackground))
            }
            
            
            
        })
        .onDisappear(perform: {
            activeSheet = nil
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



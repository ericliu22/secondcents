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
    @State var toolPickerActive: Bool = false
    @State private var draggingItem: CanvasWidget?
    @State private var inSettingsView: Bool = false
    @State private var photoLinkedToProfile: Bool = false
    @State private var widgetId: String = UUID().uuidString
    @State private var toolkit: PKToolPicker = PKToolPicker()
    @State private var timer: Timer?
    
    @State private var replyWidget: CanvasWidget?
    @State private var selectedDetent: PresentationDetent = .height(50)
    
    @Bindable var viewModel = CanvasPageViewModel()
    @Environment(AppModel.self) var appModel
    
    private var spaceId: String
    
    //helps reset view
    //Eric: Idk what this is
    @State private var refreshId = UUID()
    
    init(spaceId: String) {
        self.spaceId = spaceId
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
            guard let draggingItem = draggingItem else {
                print("Failed to intialize dragging item")
                return false
            }
            
            
            let x = roundToTile(number: location.x)
            let y = roundToTile(number: location.y)
            
            
            SpaceManager.shared.moveWidget(spaceId: spaceId, widgetId: draggingItem.id.uuidString, x: x, y: y)
            
            self.draggingItem = nil
            return true
        }
        
        .overlay(
            DrawingCanvas(canvas: $viewModel.canvas, toolPickerActive: $toolPickerActive, toolPicker: $toolkit, spaceId: spaceId)
                .allowsHitTesting(toolPickerActive)
                .clipped() // Ensure the content does not overflow
                .animation(.spring()) // Optional: Add some animation
                .frame(width: FRAME_SIZE, height: FRAME_SIZE)
        )
        
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
                viewModel.activeSheet = .newWidgetView
                
            }, label: {
                Image(systemName: "plus.circle")
            })
        }
        
        //SPACE SETTINGS
        ToolbarItem(placement: .topBarTrailing) {
            
            NavigationLink {
                
                SpaceSettingsView(spaceId: spaceId)
                    .onAppear {
                        viewModel.activeSheet = nil
                        inSettingsView = true
                    }
                    .onDisappear {
                        viewModel.activeSheet = .chat
                        inSettingsView = false
                    }
            } label: {
                Image(systemName: "ellipsis")
                
            }
        }
    }
    
    
    func GridView() -> some View {
        ForEach(viewModel.canvasWidgets, id:\.id) { widget in
            //main widget
            MediaView(widget: widget, spaceId: spaceId)
                .environment(viewModel)
                .contextMenu(ContextMenu(menuItems: {
                    
                    EmojiReactionContextView(spaceId: spaceId, widget: widget, refreshId: $refreshId)
                    widgetButton(widget: widget)
                    
                    // Reply button
                    Button(action: {
                        viewModel.activeSheet = .chat
                        selectedDetent = .large
                        replyWidget = widget
                    }, label: {
                        Label("Reply", systemImage: "arrowshape.turn.up.left")
                        //                            Image(systemName: "arrowshape.turn.up.left")
                    })
                    // Delete button
                    
                    
                    Button(role: .destructive) {
                        if let index = viewModel.canvasWidgets.firstIndex(of: widget)  {
                            viewModel.canvasWidgets.remove(at: index)
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
                        
                        viewModel.activeSheet = .chat
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
            
            
                .overlay() {
                    viewModel.selectedWidget == nil/* && draggingItem == nil */?
                    EmojiCountOverlayView(spaceId: spaceId, widget: widget)
                        .offset(y: TILE_SIZE/2)
                        .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                        .id(refreshId)
                    
                    : nil
                }
            
                .animation(.spring(), value: widget.x) // Add animation for x position
                .animation(.spring(), value: widget.y) // Add animation for y position
            
                .draggable(widget) {
                    MediaView(widget: widget, spaceId: spaceId)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        .frame(
                            width: TILE_SIZE,
                            height: TILE_SIZE
                        )
                        .onAppear{
                            draggingItem = widget
                        }
                        .environment(viewModel)
                }
            
        }
    }
    
    @ViewBuilder
    func widgetButton( widget: CanvasWidget) -> some View {
        switch widget.media {
        case .poll:
            Button(action: {
                viewModel.activeWidget = widget
                viewModel.activeSheet =  .poll
            }, label: {
                Label("Open Poll", systemImage: "list.clipboard")
            })
        case .todo:
            Button(action: {
                viewModel.activeWidget = widget
                viewModel.activeSheet = .todo
            }, label: {
                
                Label("Open List", systemImage: "checklist")
            })
        case .map:
            Button(action: {
                if let location = widget.location {
                    viewModel.openMapsApp(location: location)
                }
            }, label: {
                
                Label("Open Map", systemImage: "mappin.and.ellipse")
            })
        case .link:
            Button(action:{
                if let url = widget.mediaURL {
                    viewModel.openLink(url: url)
                }
            }, label: {
                
                Label("Open Link", systemImage: "link")
            })
        case .image:
            Button(action: {
                viewModel.activeWidget = widget
                viewModel.activeSheet = .image
            }, label: {
                
                Label("Open Image", systemImage: "photo")
            })
        case .video:
            Button(action: {
                viewModel.activeWidget = widget
                viewModel.activeSheet = .video
            }, label: {
                
                Label("Open Video", systemImage: "video")
            })
        case .calendar:
            Button(action: {
                viewModel.activeWidget = widget
                viewModel.activeSheet = .calendar
            }, label: {
                
                Label("Select Availability", systemImage: "calendar")
            })
            
        default:
            EmptyView()
        }
    }
    
    
    
    @Environment(\.undoManager) private var undoManager
    var body: some View {
        ZoomableScrollView(toolPickerActive: $toolPickerActive) {
            canvasView()
                .frame(width: FRAME_SIZE * 1.5, height: FRAME_SIZE * 1.5)
                .ignoresSafeArea()
            //add new widget view and ChatSHEET
            
                .onAppear(perform: {
                    viewModel.activeSheet = .chat
                })
                .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
                    viewModel.removeExpiredStrokes()
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
                        viewModel.attachDrawingListener()
                        viewModel.attachWidgetListener()
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
                    appModel.navigationMutex.broadcast()
                    print("signaled")
                }
            }
        })
        .ignoresSafeArea()
        .sheet(item: $viewModel.activeSheet, onDismiss: {
            
            replyWidget = nil
            viewModel.activeWidget = nil
            
            //get chat to show up at all times
            if !inSettingsView && viewModel.activeSheet == nil{
                inSettingsView = false
                viewModel.activeSheet = .chat
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
                NewWidgetView(widgetId: widgetId, spaceId: spaceId, photoLinkedToProfile: $photoLinkedToProfile)
                //                            .presentationBackground(Color(UIColor.systemBackground))
                    .presentationBackground(.thickMaterial)
            case .chat:
                
                
                NewChatView(spaceId: spaceId, replyWidget: $replyWidget, detent: $selectedDetent)
                
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
                PollWidgetSheetView(widget: waitForVariable{viewModel.activeWidget}, spaceId: spaceId)
            case .newTextView:
                NewTextWidgetView(spaceId: spaceId)
                    .presentationBackground(Color(UIColor.systemBackground))
            case .todo:
                TodoWidgetSheetView(widget: waitForVariable{viewModel.activeWidget}, spaceId: spaceId)
                    .presentationBackground(Color(UIColor.systemBackground))
            case .image:
                ImageWidgetSheetView(widget: waitForVariable{viewModel.activeWidget}, spaceId: spaceId)
                    .presentationBackground(.thickMaterial)
            case .video:
                VideoWidgetSheetView(widget: waitForVariable{viewModel.activeWidget}, spaceId: spaceId)
                    .presentationBackground(.thickMaterial)
            case .calendar:
                CalendarWidgetSheetView(widgetId:  waitForVariable{viewModel.activeWidget?.id.uuidString}, spaceId: spaceId)
                    .presentationBackground(.thickMaterial)
                    .environment(viewModel)
            }
            
        })
        
        .onDisappear(perform: {
            viewModel.activeSheet = nil
            appModel.inSpace = false
            appModel.currentSpaceId = nil
            print("CANVASPAGE DISAPPEARED")
            print("CANVASPAGE: appModel.inSpace \(appModel.inSpace)")
            
        })
        .background(  Color(UIColor.secondarySystemBackground))
        .environment(viewModel)
    }
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"87D5AC3A-24D8-4B23-BCC7-E268DBBB036F")
    }
}

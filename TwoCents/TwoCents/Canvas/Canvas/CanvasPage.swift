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


//CanvasViewModelDelegate is so that we can call dismiss the view from viewModel
struct CanvasPage: View, CanvasViewModelDelegate {
    
    @State var viewModel: CanvasPageViewModel
    @Environment(AppModel.self) var appModel
    @Environment(\.presentationMode) var presentationMode
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.viewModel = CanvasPageViewModel(spaceId: spaceId)
    }
    
    func dismissView() {
        presentationMode.wrappedValue.dismiss()
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
            .allowsHitTesting(viewModel.isDrawing)
        }
//        .drawingGroup()
        
        .clipped() // Ensure the content does not overflow
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
//            DrawingCanvas(spaceId: spaceId)
//                .allowsHitTesting(viewModel.isDrawing)
//                .clipped() // Ensure the content does not overflow
//                .animation(.spring()) // Optional: Add some animation
//                .frame(width: FRAME_SIZE, height: FRAME_SIZE)
        }
        .dropDestination(for: CanvasWidget.self) { receivedWidgets, location in
            
            guard let draggingItem = receivedWidgets.first else {
                print("Failed to intialize dragging item")
                return false
            }
            let x = roundToTile(number: location.x)
            let y = roundToTile(number: location.y)
            
            SpaceManager.shared.moveWidget(spaceId: spaceId, widgetId: draggingItem.id.uuidString, x: x, y: y)
            
            return true
        }
        
    }
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        if viewModel.isDrawing{
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
//        ToolbarItem(placement: .topBarTrailing) {
//            Button(action: {
//                viewModel.isDrawing.toggle()
//            }, label: {
//                viewModel.isDrawing
//                ? Image(systemName: "pencil.tip.crop.circle.fill")
//                : Image(systemName: "pencil.tip.crop.circle")
//            })
//        }
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
                        viewModel.inSettingsView = true
                    }
                    .onDisappear {
                        viewModel.activeSheet = .chat
                        viewModel.inSettingsView = false
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
                    
                    EmojiReactionContextView(spaceId: spaceId, widget: widget, refreshId: $viewModel.refreshId)
                    widgetButton(widget: widget)
                    // Reply button
                    Button(action: {
                        viewModel.activeSheet = .chat
                        viewModel.selectedDetent = .large
                        viewModel.replyWidget = widget
                    }, label: {
                        Label("Reply", systemImage: "arrowshape.turn.up.left")
                        //                            Image(systemName: "arrowshape.turn.up.left")
                    })
                    // Delete button
                    
                    Button(role: .destructive) {
                        viewModel.deleteWidget(widget: widget)
                    } label: {
                        
                        Label("Delete", systemImage: "trash")
                        
                    }
                }))
                .cornerRadius(CORNER_RADIUS)
                .frame(
                    width: widget.width,
                    height: widget.height
                )
                .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                .offset(x: widget.width/2, y: widget.height/2)
                .overlay {
                    viewModel.selectedWidget == nil ?
                    EmojiCountOverlayView(spaceId: spaceId, widget: widget)
                        .offset(x: widget.width/2, y: widget.height)
                        .position(x: widget.x ??  FRAME_SIZE/2, y: widget.y ?? FRAME_SIZE/2)
                        .id(viewModel.refreshId)
                    
                    : nil
                }
                .animation(.spring(), value: widget.x) // Add animation for x position
                .animation(.spring(), value: widget.y) // Add animation for y position
                .draggable(widget) {
                    MediaView(widget: widget, spaceId: spaceId)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        .frame(
                            width: widget.width,
                            height: widget.height
                        )
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
        case .text:
            Button(action: {
                viewModel.activeWidget = widget
                viewModel.activeSheet = .text
            }, label: {
                Label("Edit Text", systemImage: "message")
            })
        default:
            EmptyView()
        }
    }
    
    @Environment(\.undoManager) private var undoManager
    var body: some View {
        
        ZoomableScrollView {
            canvasView()
                .frame(width: FRAME_SIZE * 1.5, height: FRAME_SIZE * 1.5)
                .ignoresSafeArea()
                .toolbar(.hidden, for: .tabBar)
                .toolbar {toolbar()}
                .navigationBarTitleDisplayMode(.inline)
                //SHOW BACKGROUND BY CHANGING BELOW TO VISIBLE
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationTitle(viewModel.isDrawing ? "" : viewModel.space?.name ?? "" )
                .background(Color(UIColor.secondarySystemBackground))
                //IMPORTANT
                //onAppear and task must must must be here or else ZoomableScrollView is fucked
                //Don't know the reason why -Eric
                .onAppear(perform: {
                    viewModel.activeSheet = .chat
                    viewModel.delegate = self
                    appModel.currentSpaceId = spaceId
                    appModel.inSpace = true
                    Task {
                        await readNotifications(spaceId: spaceId, userId: appModel.user!.userId)
                    }
                })
                .task{
                    do {
                        try await viewModel.loadCurrentSpace(spaceId: spaceId)
                        //try await viewModel.loadCurrentUser()
                        viewModel.attachWidgetListener()
                    } catch {
                        //EXIT IF SPACE DOES NOT EXIST
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    if let userInSpace = try? await viewModel.space?.members?.contains(getUID() ?? ""){
                        print(userInSpace)
                        if !userInSpace {
                            //if user not in space, exit
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            
        }
        .ignoresSafeArea()
        .sheet(item: $viewModel.activeSheet, onDismiss: {
            viewModel.sheetDismiss()
        }, content: { item in
            
            switch item {
            case .newWidgetView:
                NewWidgetView(spaceId: spaceId)
                //                            .presentationBackground(Color(UIColor.systemBackground))
                    .presentationBackground(.thickMaterial)
            case .chat:
                    ChatView(spaceId: spaceId)
                        .presentationBackground(Color(UIColor.systemBackground))
                        .presentationDetents([.height(50),.large], selection: $viewModel.selectedDetent)
                        .presentationCornerRadius(20)
                        .presentationBackgroundInteraction(.enabled)
                        .onChange(of: viewModel.selectedDetent) {
                            if viewModel.selectedDetent != .large {
                                
                                withAnimation {
                                    viewModel.replyWidget = nil
                                    
                                }
                                
                                print("detent is 50")
                            }
                        }
                        .onAppear {
                            viewModel.selectedDetent = .height(50)
                        }
                        .interactiveDismissDisabled()
                
                
                
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
            case .text:
                EditTextWidgetView(widget: waitForVariable{viewModel.activeWidget}, spaceId: spaceId)
                    .presentationBackground(.thickMaterial)
                    .environment(viewModel)
            }
            
        })
        .onChange(of: appModel.shouldNavigateToSpace) {
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
        }
        .onDisappear {
            viewModel.activeSheet = nil
            appModel.inSpace = false
            appModel.currentSpaceId = nil
            Task {
                await readNotifications(spaceId: spaceId, userId: appModel.user!.userId)
            }
        }
        .background(  Color(UIColor.secondarySystemBackground))
        .environment(viewModel)
    }
}


struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId:"87D5AC3A-24D8-4B23-BCC7-E268DBBB036F")
    }
}

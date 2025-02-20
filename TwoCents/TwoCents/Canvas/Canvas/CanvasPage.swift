//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import FirebaseCore
import FirebaseFirestore
import PencilKit
import SwiftUI

//CONSTANTS
let TILE_SIZE: CGFloat = 150
let TILE_SPACING: CGFloat = 30
let MAX_ZOOM: CGFloat = 3.0
let MIN_ZOOM: CGFloat = 0.6
let CORNER_RADIUS: CGFloat = 15
let FRAME_SIZE: CGFloat = 2000
let WIDGET_SPACING: CGFloat = TILE_SIZE + TILE_SPACING
let STARTING_POINT: CGPoint = CGPoint(x: 500, y: 500)

//CanvasViewModelDelegate is so that we can call dismiss the view from viewModel
struct CanvasPage: View, CanvasViewModelDelegate {

    @State var viewModel: CanvasPageViewModel
    @Environment(AppModel.self) var appModel
    @Environment(\.presentationMode) var presentationMode
    let widgetId: String?

    private let spaceId: String

    init(spaceId: String, widgetId: String? = nil) {
        self.spaceId = spaceId
        self.viewModel = CanvasPageViewModel(spaceId: spaceId)
        self.widgetId = widgetId
    }

    func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }

    func Background() -> some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = TILE_SPACING  // Adjust this value for the spacing between dots
                let width = geometry.size.width
                let height = geometry.size.height

                for x in stride(from: 4, through: width, by: spacing) {
                    for y in stride(from: 4, through: height, by: spacing) {
                        path.addEllipse(
                            in: CGRect(x: x, y: y, width: 2, height: 2))
                    }
                }
            }
            .fill(Color(UIColor.secondaryLabel))  // Dot color
            .allowsHitTesting(viewModel.canvasMode == .drawing)
        }
        //        .drawingGroup()

        .clipped()  // Ensure the content does not overflow
        .frame(width: FRAME_SIZE, height: FRAME_SIZE)
    }

    func canvasView() -> some View {
        ZStack {
            Color("bgColor")
                .clipped()
                .frame(width: FRAME_SIZE, height: FRAME_SIZE)

            Background()
            GridView()
            NewWidgetOverlay()
            // Uncomment the following if you want a drawing canvas as well:
            // DrawingCanvas(spaceId: spaceId)
            //    .allowsHitTesting(viewModel.isDrawing)
            //    .clipped() // Ensure the content does not overflow
            //    .animation(.spring()) // Optional: Add some animation
            //    .frame(width: FRAME_SIZE, height: FRAME_SIZE)
        }
        .coordinateSpace(name: "canvas")
        .dropDestination(for: String.self) { receivedItems, location in
            viewModel.canvasMode = .normal
            // receivedItems now is an array of Strings.
            guard let widgetId = receivedItems.first else {
                print("No widget id found in drop items")
                return false
            }
            // Look up the widget from your viewModel by id.
            guard let uuid = UUID(uuidString: widgetId) else {
                print("Could not find widget with id \(widgetId)")
                return false
            }
            guard let draggedWidget = viewModel.canvasWidgets[id: uuid] else {
                print("Could not find widget with id \(widgetId)")
                return false
            }
            let proposedPoint = snapWidgetToGrid(draggedWidget, CGPoint(x: location.x, y: location.y))
            if !viewModel.canPlaceWidget(
                draggedWidget, at: proposedPoint)
            {
                print("Collision detected—drop rejected")
                return false
            }
            SpaceManager.shared.moveWidget(
                spaceId: spaceId,
                widgetId: draggedWidget.id.uuidString,
                x: proposedPoint.x,
                y: proposedPoint.y)
            return true
        }
    }

    @ViewBuilder
    func NewWidgetOverlay() -> some View {
        if viewModel.canvasMode == .placement {
            if let widget = viewModel.newWidget {
                let position = snapWidgetToGrid(widget, viewModel.widgetCursor)
                ZStack {
                    MediaView(widget: widget, spaceId: spaceId)
                        .environment(viewModel)
                        .cornerRadius(CORNER_RADIUS)
                        .frame(
                            width: widget.width,
                            height: widget.height
                        )
                        .animation(.spring(), value: widget.x)  // Add animation for x position
                        .animation(.spring(), value: widget.y)  // Add animation for y position
                    Color(
                            viewModel.canPlaceWidget(
                                widget, at: position)
                            ? Color.green : Color.red)
                    .opacity(0.3)
                    .cornerRadius(CORNER_RADIUS)
                    .frame(
                        width: widget.width,
                        height: widget.height
                    )
                }
                .position(position)
            }
        } else {
            EmptyView()
        }
    }

    @ToolbarContentBuilder
    func CanvasToolbar() -> some ToolbarContent {
        if viewModel.canvasMode == .drawing {
            //undo
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        undoManager?.undo()
                    },
                    label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                    })
            }
            //redo
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        undoManager?.redo()
                    },
                    label: {
                        Image(systemName: "arrow.uturn.forward.circle")
                    })
            }
        }
        // Uncomment if you want pencilkit toggle
        // ToolbarItem(placement: .topBarTrailing) {
        //     Button(action: {
        //         viewModel.isDrawing.toggle()
        //     }, label: {
        //         viewModel.isDrawing
        //         ? Image(systemName: "pencil.tip.crop.circle.fill")
        //         : Image(systemName: "pencil.tip.crop.circle")
        //     })
        // }
        //add widget
        if viewModel.canvasMode != .placement {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(
//                    action: {
//                        viewModel.activeSheet = .newWidgetView(
//                            startingLocation: nil)
//                    },
//                    label: {
//                        Image(systemName: "plus.circle")
//                    })
//            }

            //SPACE SETTINGS
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SpaceSettingsView(spaceId: spaceId)
                        .environment(viewModel)
                        .onAppear {
                            viewModel.activeSheet = nil
                            viewModel.inSubView = true
                        }
                        .onDisappear {
                            viewModel.inSubView = false
                        }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {

                        viewModel.confirmPlacement(
                            x: viewModel.widgetCursor.x,
                            y: viewModel.widgetCursor.y)
                    },
                    label: {
                        Image(systemName: "checkmark.circle")
                    })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.canvasMode = .normal
                        guard let newWidget = viewModel.newWidget else {
                            return
                        }
                        SpaceManager.shared.deleteAssociatedWidget(
                            spaceId: spaceId, widgetId: newWidget.id.uuidString,
                            media: newWidget.media)
                    },
                    label: {
                        Image(systemName: "x.circle")
                    })
            }
        }
    }

    // MARK: - GridView with fixed draggable behavior
    func GridView() -> some View {
        ForEach(viewModel.canvasWidgets, id: \.id) { widget in
            // Main widget view
            ZStack {
                DraggableView(
                    onDrag: {
                        viewModel.canvasMode = .dragging
                        viewModel.dragWidget = widget
                        let provider = NSItemProvider(
                            object: NSString(string: widget.id.uuidString))
                        let dragItem = UIDragItem(itemProvider: provider)
                        dragItem.localObject = widget  // attach the widget so we know which one is being dragged
                        return [dragItem]
                    },
                    onDrop: { session, dropPoint in
                        // Retrieve the dragged widget from the session's drag items.
                        viewModel.canvasMode = .normal
                        viewModel.dragWidget = nil
                        guard
                            let draggedWidget = session.items.first?.localObject
                                as? CanvasWidget
                        else {
                            print("Failed to retrieve the dragged widget")
                            return false
                        }
                        let proposedPoint = snapWidgetToGrid(draggedWidget, CGPoint(x: dropPoint.x, y: dropPoint.y))
                        if !viewModel.canPlaceWidget(
                            draggedWidget, at: proposedPoint)
                        {
                            print("Collision detected—drop rejected")
                            return false
                        }
                        SpaceManager.shared.moveWidget(
                            spaceId: spaceId,
                            widgetId: draggedWidget.id.uuidString,
                            x: proposedPoint.x,
                            y: proposedPoint.y)
                        return true
                    }

                ) {
                    MediaView(widget: widget, spaceId: spaceId)
                        .environment(viewModel)
                        .cornerRadius(CORNER_RADIUS)
                        .frame(width: widget.width, height: widget.height)
                        .contextMenu(
                            ContextMenu(menuItems: {

                                EmojiReactionContextView(
                                    spaceId: spaceId, widget: widget,
                                    refreshId: $viewModel.refreshId)
                                widgetButton(widget: widget)
                                // Reply button
                                //@TODO: This will not work for the time being
                                Button(
                                    action: {
                                        viewModel.activeSheet = .reply
                                        viewModel.selectedDetent = .large
                                        viewModel.replyWidget = widget
                                        viewModel.canvasMode = .normal
                                    },
                                    label: {
                                        Label(
                                            "Reply",
                                            systemImage:
                                                "arrowshape.turn.up.left")
                                    })
                                // Delete button

                                Button(role: .destructive) {
                                    viewModel.deleteWidget(widget: widget)
                                    viewModel.canvasMode = .normal
                                } label: {

                                    Label("Delete", systemImage: "trash")

                                }
                                ShareLink(
                                    item: viewModel.generateWidgetLink(
                                        widget: widget)
                                ) {
                                    Label(
                                        "Share widget",
                                        systemImage: "square.and.arrow.up")
                                    .onTapGesture {
                                        viewModel.canvasMode = .normal
                                    }

                                }
                            })
                        )
                        .cornerRadius(CORNER_RADIUS)
                }
                .frame(width: widget.width, height: widget.height)
                .position(
                    x: widget.x ?? FRAME_SIZE / 2,
                    y: widget.y ?? FRAME_SIZE / 2
                )
                .overlay {
                    if viewModel.selectedWidget == nil {
                        EmojiCountOverlayView(
                            spaceId: spaceId, widget: widget
                        )
                        .offset(y: widget.height / 2)
                        .position(
                            x: widget.x ?? FRAME_SIZE / 2,
                            y: widget.y ?? FRAME_SIZE / 2
                        )
                        .id(viewModel.refreshId)
                    } else {
                        EmptyView()
                    }
                }
                // Disable position animations while dragging to avoid jittery behavior

                // Optional unread indicator overlay
                if viewModel.unreadWidgets.contains(where: {
                    $0 == widget.id.uuidString
                }) {
                    NotificationWidgetWrapper(widgetUserId: widget.userId)
                        .position(
                            x: widget.x ?? FRAME_SIZE / 2,
                            y: widget.y ?? FRAME_SIZE / 2)
                        .offset(
                            x: -widget.width/2,
                            y: -widget.height/2
                        )
                }
            }
        }
    }

    @ViewBuilder
    func widgetButton(widget: CanvasWidget) -> some View {
        switch widget.media {
        case .poll:
            Button(
                action: {
                    viewModel.activeWidget = widget
                    viewModel.activeSheet = .poll
                },
                label: {
                    Label("Open Poll", systemImage: "list.clipboard")
                })
        case .todo:
            Button(
                action: {
                    viewModel.activeWidget = widget
                    viewModel.activeSheet = .todo
                },
                label: {
                    Label("Open List", systemImage: "checklist")
                })
        case .map:
            Button(
                action: {
                    if let location = widget.location {
                        viewModel.openMapsApp(location: location)
                    }
                },
                label: {
                    Label("Open Map", systemImage: "mappin.and.ellipse")
                })
        case .link:
            Button(
                action: {
                    if let url = widget.mediaURL {
                        viewModel.openLink(url: url)
                    }
                },
                label: {
                    Label("Open Link", systemImage: "link")
                })
        case .image:
            Button(
                action: {
                    viewModel.activeWidget = widget
                    viewModel.activeSheet = .image
                },
                label: {
                    Label("Open Image", systemImage: "photo")
                })
        case .video:
            Button(
                action: {
                    viewModel.activeWidget = widget
                    viewModel.activeSheet = .video
                },
                label: {
                    Label("Open Video", systemImage: "video")
                })
        case .calendar:
            Button(
                action: {
                    viewModel.activeWidget = widget
                    viewModel.activeSheet = .calendar
                },
                label: {
                    Label("Select Availability", systemImage: "calendar")
                })
        case .text:
            if appModel.user?.userId == widget.userId {
                Button(
                    action: {
                        viewModel.activeWidget = widget
                        viewModel.activeSheet = .text
                    },
                    label: {
                        Label("Edit Text", systemImage: "message")
                    })
            }
        default:
            EmptyView()
        }
    }

    @Environment(\.undoManager) private var undoManager
    var body: some View {
        ZStack {
            ZoomableScrollView {
                canvasView()
                    .frame(width: FRAME_SIZE * 1.5, height: FRAME_SIZE * 1.5)
                    .ignoresSafeArea()
                    .toolbar(.hidden, for: .tabBar)
                    .toolbar { CanvasToolbar() }
                    .navigationBarTitleDisplayMode(.inline)
                    //SHOW BACKGROUND BY CHANGING BELOW TO VISIBLE
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .navigationTitle(
                        viewModel.canvasMode != .normal
                            ? "" : viewModel.space?.name ?? ""
                    )
                    .background(Color(UIColor.secondarySystemBackground))
                    // IMPORTANT: onAppear and task must be here or else ZoomableScrollView misbehaves.
                    .onAppear {
                        viewModel.activeSheet = nil
                        viewModel.delegate = self
                    }
                    .task {
                        do {
                            try await viewModel.loadCurrentSpace()
                            viewModel.attachWidgetListener()
                            if let user = appModel.user {
                                await viewModel.fetchUsers(
                                    currentUserId: user.userId)

                            }
                            // Scroll to the specified widget after listener attachment.
                            if let id = widgetId {
                                viewModel.scrollTo(widgetId: id)
                            }
                        } catch {
                            // EXIT IF SPACE DOES NOT EXIST
                            presentationMode.wrappedValue.dismiss()
                        }
                        if let user = appModel.user {
                            viewModel.attachUnreadListener(
                                userId: user.userId)
                        }
                    }
            }
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(viewModel.unreadWidgets, id: \.self) { widgetId in
                    OffScreenIndicator(widgetId: widgetId)
                        .environment(viewModel)
                        // Ensure full-size frame for proper positioning
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .ignoresSafeArea()
            VStack {
                Spacer()
                BottomButtons()
            }
        }
        .ignoresSafeArea()
        .sheet(
            item: $viewModel.activeSheet,
            onDismiss: {
                viewModel.sheetDismiss()
            },
            content: { item in
                switch item {
                case .newWidgetView(let startingLocation):
                    NewWidgetView(
                        spaceId: spaceId, startingLocation: startingLocation
                    )
                    .environment(viewModel)
                    .presentationBackground(.thickMaterial)
                case .poll:
                    PollWidgetSheetView(
                        widget: waitForVariable { viewModel.activeWidget },
                        spaceId: spaceId)
                case .newTextView:
                    NewTextWidgetView(spaceId: spaceId)
                        .presentationBackground(Color(UIColor.systemBackground))
                case .todo:
                    TodoWidgetSheetView(
                        widget: waitForVariable { viewModel.activeWidget },
                        spaceId: spaceId
                    )
                    .presentationBackground(Color(UIColor.systemBackground))
                case .image:
                    ImageWidgetSheetView(
                        widget: waitForVariable { viewModel.activeWidget },
                        spaceId: spaceId
                    )
                    .presentationBackground(.thickMaterial)
                case .video:
                    VideoWidgetSheetView(
                        widget: waitForVariable { viewModel.activeWidget },
                        spaceId: spaceId
                    )
                    .presentationBackground(.thickMaterial)
                case .calendar:
                    CalendarWidgetSheetView(
                        widgetId: waitForVariable {
                            viewModel.activeWidget?.id.uuidString
                        },
                        spaceId: spaceId
                    )
                    .presentationBackground(.thickMaterial)
                    .environment(viewModel)
                case .text:
                    EditTextWidgetView(
                        widget: waitForVariable { viewModel.activeWidget },
                        spaceId: spaceId
                    )
                    .presentationBackground(.thickMaterial)
                    .environment(viewModel)
                case .reply:
                    ChatSelectionView()
                        .environment(viewModel)
                }
            }
        )
        .onDisappear {
            viewModel.activeSheet = nil
        }
        .background(Color(UIColor.secondarySystemBackground))
        .environment(viewModel)
    }
}

struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage(spaceId: "87D5AC3A-24D8-4B23-BCC7-E268DBBB036F")
    }
}

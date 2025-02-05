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
let db = Firestore.firestore()
/*
 Strategy for limit widget editing to user: load user, load widget creator for each widget --> compare and show separate views
 */

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
        .dropDestination(for: CanvasWidget.self) { receivedWidgets, location in
            viewModel.canvasMode = .normal
            guard let draggingItem = receivedWidgets.first else {
                print("Failed to intialize dragging item")
                return false
            }
            let x = roundToTile(number: location.x)
            let y = roundToTile(number: location.y)

            SpaceManager.shared.moveWidget(
                spaceId: spaceId,
                widgetId: draggingItem.id.uuidString,
                x: x,
                y: y
            )

            return true
        }
    }

    @ViewBuilder
    func NewWidgetOverlay() -> some View {
        if viewModel.canvasMode == .placement {
            if let widget = viewModel.newWidget {
                MediaView(widget: widget, spaceId: spaceId)
                    .environment(viewModel)
                    .cornerRadius(CORNER_RADIUS)
                    .frame(
                        width: widget.width,
                        height: widget.height
                    )
                    .position(viewModel.widgetCursor)
                    .offset(x: widget.width / 2, y: widget.height / 2)
                    .animation(.spring(), value: widget.x)  // Add animation for x position
                    .animation(.spring(), value: widget.y)  // Add animation for y position
            }
        } else {
            EmptyView()
        }
    }

    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.activeSheet = .newWidgetView
                    },
                    label: {
                        Image(systemName: "plus.circle")
                    })
            }

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
                        viewModel.confirmPlacement()
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
                        viewModel.deleteAssociatedWidget(
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
                MediaView(widget: widget, spaceId: spaceId)
                    .environment(viewModel)
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
                                },
                                label: {
                                    Label(
                                        "Reply",
                                        systemImage: "arrowshape.turn.up.left")
                                })
                            // Delete button

                            Button(role: .destructive) {
                                viewModel.deleteWidget(widget: widget)
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
                            }
                        })
                    )
                    .cornerRadius(CORNER_RADIUS)
                    .frame(width: widget.width, height: widget.height)
                    .position(
                        x: widget.x ?? FRAME_SIZE / 2,
                        y: widget.y ?? FRAME_SIZE / 2
                    )
                    .offset(x: widget.width / 2, y: widget.height / 2)
                    .overlay {
                        if viewModel.selectedWidget == nil {
                            EmojiCountOverlayView(
                                spaceId: spaceId, widget: widget
                            )
                            .offset(x: widget.width / 2, y: widget.height)
                            .position(
                                x: widget.x ?? FRAME_SIZE / 2,
                                y: widget.y ?? FRAME_SIZE / 2
                            )
                            .id(viewModel.refreshId)
                        } else {
                            EmptyView()
                        }
                    }
                    .draggable(widget) {
                        // Drag preview – note the removed .onAppear and disabled animations via transaction
                        MediaView(widget: widget, spaceId: spaceId)
                            .contentShape(
                                .dragPreview,
                                RoundedRectangle(
                                    cornerRadius: CORNER_RADIUS,
                                    style: .continuous)
                            )
                            .frame(width: widget.width, height: widget.height)
                            .environment(viewModel)
                            .environment(appModel)
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                            .onDisappear {
                                viewModel.canvasMode = .normal
                            }
                    }
                    // Disable position animations while dragging to avoid jittery behavior
                    .animation(
                        viewModel.canvasMode == .dragging ? nil : .spring(),
                        value: widget.x
                    )
                    .animation(
                        viewModel.canvasMode == .dragging ? nil : .spring(),
                        value: widget.y)

                // Optional unread indicator overlay
                if viewModel.unreadWidgets.contains(where: {
                    $0 == widget.id.uuidString
                }) {
                    NotificationWidgetWrapper(widgetUserId: widget.userId)
                        .position(
                            x: widget.x ?? FRAME_SIZE / 2,
                            y: widget.y ?? FRAME_SIZE / 2)
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
                    .toolbar { toolbar() }
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
                                    currentUserId: appModel.user!.userId)

                            }
                            // Scroll to the specified widget after listener attachment.
                            if let id = widgetId {
                                viewModel.scrollTo(widgetId: id)
                            }
                        } catch {
                            // EXIT IF SPACE DOES NOT EXIST
                            presentationMode.wrappedValue.dismiss()
                        }
                        viewModel.attachUnreadListener(
                            userId: appModel.user!.userId)
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
        }
        .ignoresSafeArea()
        .sheet(
            item: $viewModel.activeSheet,
            onDismiss: {
                viewModel.sheetDismiss()
            },
            content: { item in
                switch item {
                case .newWidgetView:
                    NewWidgetView(spaceId: spaceId)
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

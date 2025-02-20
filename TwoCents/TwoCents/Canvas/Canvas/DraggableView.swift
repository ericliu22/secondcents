import SwiftUI
import UIKit

// Custom container view that restricts hit testing to its contentView.
class DraggableContainerView: UIView {
    weak var contentView: UIView?

    override var intrinsicContentSize: CGSize {
        // Return the content's size (or .zero if not available)
        return self.bounds.size
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Invalidate the intrinsic content size when layout changes.
        self.invalidateIntrinsicContentSize()
    }
}

struct DraggableView<Content: View>: UIViewRepresentable {
    let content: Content
    var onDrag: (() -> [UIDragItem])?
    var onDrop: ((UIDropSession, CGPoint) -> Bool)?
    
    @Environment(CanvasPageViewModel.self) var canvasViewModel

    init(
        onDrag: (() -> [UIDragItem])? = nil,
        onDrop: ((UIDropSession, CGPoint) -> Bool)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.onDrag = onDrag
        self.onDrop = onDrop
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(rootView: content, onDrag: onDrag, onDrop: onDrop, canvasViewModel: canvasViewModel)
    }

    func makeUIView(context: Context) -> UIView {
        // Use the custom container view instead of a plain UIView.
        let containerView = DraggableContainerView()
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true


        // Use the persistent hosting controller from the coordinator.
        let hostingController = context.coordinator.hostingController
        hostingController.view.backgroundColor = .clear
        hostingController.view.clipsToBounds = true
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingController.view)

        // Set constraints to have the hosting controller's view fill the container.
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(
                equalTo: containerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor),
        ])

        // Assign the contentView so that our custom hit testing only covers the visible content.
        containerView.contentView = hostingController.view

        // Add UIKit drag interaction.
        let dragInteraction = UIDragInteraction(delegate: context.coordinator)
        dragInteraction.isEnabled = true
        containerView.addInteraction(dragInteraction)

        // Add UIKit drop interaction.

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Simply update the rootView of the persistent hosting controller.
        context.coordinator.hostingController.rootView = content
        context.coordinator.hostingController.view.setNeedsLayout()
        context.coordinator.hostingController.view.layoutIfNeeded()
    }

    class Coordinator: NSObject, UIDragInteractionDelegate,
        UIDropInteractionDelegate
    {
        var hostingController: UIHostingController<Content>
        var onDrag: (() -> [UIDragItem])?
        var onDrop: ((UIDropSession, CGPoint) -> Bool)?
        var canPlace: Bool = false
        
        var canvasViewModel: CanvasPageViewModel

        init(
            rootView: Content,
            onDrag: (() -> [UIDragItem])?,
            onDrop: ((UIDropSession, CGPoint) -> Bool)?,
            canvasViewModel: CanvasPageViewModel
        ) {
            self.hostingController = UIHostingController(rootView: rootView)
            self.onDrag = onDrag
            self.onDrop = onDrop
            self.canvasViewModel = canvasViewModel
        }

        // MARK: - UIDragInteractionDelegate

        func dragInteraction(
            _ interaction: UIDragInteraction,
            itemsForBeginning session: UIDragSession
        ) -> [UIDragItem] {
            if let customItems = onDrag?() {
                return customItems
            }
            let provider = NSItemProvider(object: NSString(string: "MediaView"))
            return [UIDragItem(itemProvider: provider)]
        }

        func dragInteraction(
            _ interaction: UIDragInteraction,
            previewForLifting item: UIDragItem,
            session: UIDragSession
        ) -> UITargetedDragPreview? {
            guard let view = interaction.view else { return nil }
            
            // Create preview parameters with a rounded shape.
            let parameters = UIDragPreviewParameters()
            parameters.visiblePath = UIBezierPath(
                roundedRect: view.bounds.insetBy(dx: 5, dy: 5),
                cornerRadius: 20
            )
            
            // Create a snapshot of the view.
            
            guard let widget = item.localObject as? CanvasWidget else {
                print("No widget")
                return UITargetedDragPreview(view: view, parameters: parameters)
            }
            
            
            // Create a target using the snapped center.
            
            var preview: UITargetedDragPreview?
            UIView.performWithoutAnimation {
                preview = UITargetedDragPreview(
                    view: view,
                    parameters: parameters
                )
            }
            
            return preview
        }
        
        func locationInCanvas(for session: UIDragSession,
                              in containerView: UIView) -> CGPoint? {
            // 1) Get the ZoomableScrollView.Coordinator from our shared ViewModel:
            guard let zoomCoordinator = canvasViewModel.coordinator,
                  let scrollView = zoomCoordinator.scrollView,
                  let canvasView = scrollView.subviews.first
            else {
                print("Fucked")
                return nil
            }

            // 2) Local point in the container:
            let localPoint = session.location(in: scrollView)

            // 3) Convert from container’s coords to the scrollView’s “content”:
            // 4) Unscale by the current zoom scale, if your SwiftUI code
            //    positions widgets in the "unscaled" coordinate system:
            let unscaledX = localPoint.x / scrollView.zoomScale
            let unscaledY = localPoint.y / scrollView.zoomScale

            return CGPoint(x: unscaledX, y: unscaledY)
        }

        
        func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
            guard let view = interaction.view else {
                print("No view")
                return
            }
            
            guard let widget = canvasViewModel.dragWidget else {
                print("No drag item")
                return
            }
            guard let location = locationInCanvas(for: session, in: view) else {
                print("No canvas coords")
                return
            }
            guard let widgetX = widget.x, let widgetY = widget.y else {
                print("No widget coords")
                return
            }
            
            let snappedLocation = snapWidgetToGrid(widget, location)
            
            if !canvasViewModel.canPlaceWidget(widget, at: snappedLocation) {
                print("Cannot place widget here—collision detected.")
                canPlace = false
                return
            }
            canPlace = true
            SpaceManager.shared.moveWidget(spaceId: canvasViewModel.spaceId, widgetId: widget.id.uuidString, x: snappedLocation.x, y: snappedLocation.y)
        }
        
        func dragInteraction(
            _ interaction: UIDragInteraction, canHandle session: UIDragSession
        ) -> Bool {
            return true
        }

        // MARK: - UIDropInteractionDelegate

        func dropInteraction(
            _ interaction: UIDropInteraction, canHandle session: UIDropSession
        ) -> Bool {
            return true
        }

        func dropInteraction(
            _ interaction: UIDropInteraction,
            sessionDidUpdate session: UIDropSession
        ) -> UIDropProposal {
            return UIDropProposal(operation: .move)
        }

        func dropInteraction(
            _ interaction: UIDropInteraction, performDrop session: UIDropSession
        ) {
            guard let view = interaction.view else { return }
            let dropPoint = session.location(in: view)
            UIView.performWithoutAnimation {
                if let callback = onDrop {
                    _ = callback(session, dropPoint)
                }
            }
        }

    }
}

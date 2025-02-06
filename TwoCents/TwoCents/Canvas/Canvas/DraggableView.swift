import SwiftUI
import UIKit

// Custom container view that restricts hit testing to its contentView.
class DraggableContainerView: UIView {
    weak var contentView: UIView?
    
    override var intrinsicContentSize: CGSize {
        // Return the content's size (or .zero if not available)
        return contentView?.bounds.size ?? .zero
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
    
    init(onDrag: (() -> [UIDragItem])? = nil,
         onDrop: ((UIDropSession, CGPoint) -> Bool)? = nil,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onDrag = onDrag
        self.onDrop = onDrop
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(rootView: content, onDrag: onDrag, onDrop: onDrop)
    }
    
    func makeUIView(context: Context) -> UIView {
        // Use the custom container view instead of a plain UIView.
        let containerView = DraggableContainerView()
        containerView.backgroundColor = .clear
        
        // Use the persistent hosting controller from the coordinator.
        let hostingController = context.coordinator.hostingController
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingController.view)
        
        // Set constraints to have the hosting controller's view fill the container.
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
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
    
    class Coordinator: NSObject, UIDragInteractionDelegate, UIDropInteractionDelegate {
        var hostingController: UIHostingController<Content>
        var onDrag: (() -> [UIDragItem])?
        var onDrop: ((UIDropSession, CGPoint) -> Bool)?
        
        init(rootView: Content,
             onDrag: (() -> [UIDragItem])?,
             onDrop: ((UIDropSession, CGPoint) -> Bool)?) {
            self.hostingController = UIHostingController(rootView: rootView)
            self.onDrag = onDrag
            self.onDrop = onDrop
        }
        
        // MARK: - UIDragInteractionDelegate
        
        func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
            if let customItems = onDrag?() {
                return customItems
            }
            let provider = NSItemProvider(object: NSString(string: "MediaView"))
            return [UIDragItem(itemProvider: provider)]
        }
        
        func dragInteraction(_ interaction: UIDragInteraction,
                             previewForLifting item: UIDragItem,
                             session: UIDragSession) -> UITargetedDragPreview? {
            guard let view = interaction.view else { return nil }
            let parameters = UIDragPreviewParameters()
            parameters.visiblePath = UIBezierPath(roundedRect: view.bounds.insetBy(dx: 5, dy: 5),
                                                  cornerRadius: 20)
            var preview: UITargetedDragPreview?
            UIView.performWithoutAnimation {
                preview = UITargetedDragPreview(view: view, parameters: parameters)
            }
            return preview
        }

        // MARK: - UIDropInteractionDelegate
        
        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            return true
        }
        
        
        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            return UIDropProposal(operation: .move)
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
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

//
//  DraggableView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/5.
//

//
//  DraggableView.swift
//  TwoCents
//
//  A drop‐in wrapper that wraps any SwiftUI view in a UIViewRepresentable
//  and adds UIKit drag & drop interactions.
//
//  Usage example:
//      DraggableView(onDrag: {
//          // Provide your own drag items if needed.
//          // For instance, you might create drag items from your CanvasWidget.
//          let provider = NSItemProvider(object: NSString(string: "MediaView"))
//          return [UIDragItem(itemProvider: provider)]
//      }, onDrop: { session, dropPoint in
//          // Handle the drop – for example, you could update your model using dropPoint.
//          // Return true if the drop was accepted.
//          print("Dropped at: \(dropPoint)")
//          return true
//      }) {
//          MediaView(widget: widget, spaceId: spaceId)
//      }
//
import SwiftUI
import UIKit

struct DraggableView<Content: View>: UIViewRepresentable {
    let content: Content
    /// Optional closure to provide custom drag items.
    var onDrag: (() -> [UIDragItem])?
    /// Optional closure to handle the drop action.
    var onDrop: ((UIDropSession, CGPoint) -> Bool)?
    
    init(onDrag: (() -> [UIDragItem])? = nil,
         onDrop: ((UIDropSession, CGPoint) -> Bool)? = nil,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onDrag = onDrag
        self.onDrop = onDrop
    }
    
    func makeUIView(context: Context) -> UIView {
        // Create a container view.
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Embed the SwiftUI content in a hosting controller.
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Add UIKit drag interaction.
        let dragInteraction = UIDragInteraction(delegate: context.coordinator)
        dragInteraction.isEnabled = true
        containerView.addInteraction(dragInteraction)
        
        // Add UIKit drop interaction.
        let dropInteraction = UIDropInteraction(delegate: context.coordinator)
        containerView.addInteraction(dropInteraction)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // In case your content changes, update the hosting controller’s root view.
        if let hostingController = uiView.subviews.compactMap({ $0.next as? UIHostingController<Content> }).first {
            hostingController.rootView = content
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onDrag: onDrag, onDrop: onDrop)
    }
    
    class Coordinator: NSObject, UIDragInteractionDelegate, UIDropInteractionDelegate {
        var onDrag: (() -> [UIDragItem])?
        var onDrop: ((UIDropSession, CGPoint) -> Bool)?
        
        init(onDrag: (() -> [UIDragItem])?, onDrop: ((UIDropSession, CGPoint) -> Bool)?) {
            self.onDrag = onDrag
            self.onDrop = onDrop
        }
        
        // MARK: - UIDragInteractionDelegate
        
        func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
            if let customItems = onDrag?() {
                return customItems
            }
            // Default behavior – you may adjust this to pass along data about the view.
            let provider = NSItemProvider(object: NSString(string: "MediaView"))
            return [UIDragItem(itemProvider: provider)]
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
            guard let view = interaction.view else { return nil }
            let parameters = UIDragPreviewParameters()
            parameters.visiblePath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 15)
            return UITargetedDragPreview(view: view, parameters: parameters)
        }
        
        // MARK: - UIDropInteractionDelegate
        
        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            // Accept any drop. You can add filtering based on the session if needed.
            return true
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            // Propose a move operation.
            return UIDropProposal(operation: .move)
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            guard let view = interaction.view else { return }
            let dropPoint = session.location(in: view)
            if let callback = onDrop {
                _ = callback(session, dropPoint)
            }
        }
    }
}

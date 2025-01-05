//
//  ZoomableScrollView.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/6/23.
//

import Foundation
import SwiftUI

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    @Environment(CanvasPageViewModel.self) var canvasViewModel

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 2.5
        scrollView.minimumZoomScale = 0.15
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = canvasViewModel.canvasMode != .drawing
        scrollView.contentInsetAdjustmentBehavior = .never

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content), canvasViewModel: canvasViewModel)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.isScrollEnabled = canvasViewModel.canvasMode != .drawing
        context.coordinator.hostingController.rootView = self.content
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
        updateContentSize(for: uiView)
        //@TODO: Experiment with the functionality of this
        centerContent(uiView)
        DispatchQueue.main.async {
            context.coordinator.updateCenter(for: uiView)
        }
    }
    
    func centerContent(_ uiView: UIScrollView) {
        if uiView.contentOffset == .zero {
            let initialOffsetX = (uiView.contentSize.width - uiView.bounds.width) / 2
            let initialOffsetY = (uiView.contentSize.height - uiView.bounds.height) / 2
            uiView.contentOffset = CGPoint(x: initialOffsetX, y: initialOffsetY)
        }
    }
    
    private func updateContentSize(for scrollView: UIScrollView) {
        guard let view = scrollView.subviews.first else { 
            print("ZoomableScrollView: no subview")
            return
        }
        let zoomScale = scrollView.zoomScale
        let contentSize = CGSize(width: view.intrinsicContentSize.width * zoomScale, height: view.intrinsicContentSize.height * zoomScale)
        scrollView.contentSize = contentSize
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var canvasViewModel: CanvasPageViewModel
        
        private var idleTimer: Timer?

        init(hostingController: UIHostingController<Content>, canvasViewModel: CanvasPageViewModel) {
            self.hostingController = hostingController
            self.canvasViewModel = canvasViewModel
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        private func resetIdleTimer(_ scrollView: UIScrollView) {
            idleTimer?.invalidate()
            idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self?.autoCenterOnCursor(scrollView)
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            updateCenter(for: scrollView)
            resetIdleTimer(scrollView)
        }
        
        

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateContentSize(for: scrollView)
            updateCenter(for: scrollView)
            resetIdleTimer(scrollView)
        }

        private func updateContentSize(for scrollView: UIScrollView) {
            guard let view = scrollView.subviews.first else { 
                print("ZoomableScrollView: no subview")
                return
            }
            let zoomScale = scrollView.zoomScale
            let contentSize = CGSize(width: view.intrinsicContentSize.width * zoomScale, height: view.intrinsicContentSize.height * zoomScale)
            scrollView.contentSize = contentSize
        }
        
        private func autoCenterOnCursor(_ scrollView: UIScrollView) {
            guard let hostedView = scrollView.subviews.first else { return }
            
            // 1) The subview’s unscaled size:
            //    In your code, it might be 2000×2000 or 3000×3000.
            let unscaledWidth  = hostedView.intrinsicContentSize.width
            let unscaledHeight = hostedView.intrinsicContentSize.height
            
            // 2) The model's cursor is presumably in "subview center = (0,0)" space,
            //    or maybe it's top-left based. Adjust if needed.
            //    For example, if (0,0) is the subview center, then to get the
            //    subview’s absolute coordinate for that cursor, we do:
            let cursorX = canvasViewModel.cursor.x + (unscaledWidth / 2)
            let cursorY = canvasViewModel.cursor.y + (unscaledHeight / 2)
            
            // 3) Convert from unscaled coords to zoomed coords:
            let zoomedX = cursorX * scrollView.zoomScale
            let zoomedY = cursorY * scrollView.zoomScale
            
            // 4) We want `zoomedX, zoomedY` to appear at the center of the scrollView's visible area.
            //    So the offset is that point minus half of the scrollView’s width/height:
            let offsetX = zoomedX - (scrollView.bounds.width / 2)
            let offsetY = zoomedY - (scrollView.bounds.height / 2)
            
            // 5) Clamp offset so we don’t scroll beyond content bounds:
            let maxOffsetX = scrollView.contentSize.width  - scrollView.bounds.width
            let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height
            
            let clampedX = max(0, min(offsetX, maxOffsetX))
            let clampedY = max(0, min(offsetY, maxOffsetY))
            
            // 6) Animate the scroll so the user sees it smoothly:
            scrollView.setContentOffset(CGPoint(x: clampedX, y: clampedY), animated: true)
        }

        
        func updateCenter(for scrollView: UIScrollView) {
            guard let hostedView = scrollView.subviews.first,
                  hostedView.intrinsicContentSize.width  > 0,
                  hostedView.intrinsicContentSize.height > 0 else {
                print("updateCenter: subview not ready yet")
                return
            }
            // 1) The center in the zoomed coordinate system:
            let zoomedCenterX = scrollView.contentOffset.x + (scrollView.bounds.width / 2)
            let zoomedCenterY = scrollView.contentOffset.y + (scrollView.bounds.height / 2)
            
            // 2) Convert to unscaled coordinates by dividing out zoomScale:
            var unscaledCenterX = zoomedCenterX / scrollView.zoomScale
            var unscaledCenterY = zoomedCenterY / scrollView.zoomScale
            
            // 3) If you want (0,0) to be the subview’s center:
            let unscaledWidth  = hostedView.intrinsicContentSize.width
            let unscaledHeight = hostedView.intrinsicContentSize.height
            
            unscaledCenterX -= unscaledWidth  / 2
            unscaledCenterY -= unscaledHeight / 2
            
            // 4) Assign to your ViewModel
            let centerPoint = CGPoint(
                x: roundToTile(number: unscaledCenterX),
                y: roundToTile(number: unscaledCenterY))
            canvasViewModel.cursor = centerPoint
        }

    }
}

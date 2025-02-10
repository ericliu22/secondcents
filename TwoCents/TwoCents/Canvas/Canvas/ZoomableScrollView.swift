//
//  ZoomableScrollView.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/6/23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content

    @Environment(CanvasPageViewModel.self) var canvasViewModel
    //@TODO: Can change this with just user lmao
    @Environment(AppModel.self) var appModel

    init(
        @ViewBuilder content: () -> Content
    ) {
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

//        let edgePanGesture = UIPanGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleEdgePan(_:))
//        )
//        edgePanGesture.delegate = context.coordinator
//        scrollView.addGestureRecognizer(edgePanGesture)

        context.coordinator.scrollView = scrollView
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        let c = Coordinator(
            hostingController: UIHostingController(rootView: self.content),
            canvasViewModel: canvasViewModel,
            appModel: appModel
        )
        // 1) Fire the callback
        canvasViewModel.coordinator = c
        c.startPeriodicCheck()
        return c
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
            let initialOffsetX =
                (uiView.contentSize.width - uiView.bounds.width) / 2
            let initialOffsetY =
                (uiView.contentSize.height - uiView.bounds.height) / 2
            uiView.contentOffset = CGPoint(x: initialOffsetX, y: initialOffsetY)
        }
    }

    private func updateContentSize(for scrollView: UIScrollView) {
        guard let view = scrollView.subviews.first else {
            print("ZoomableScrollView: no subview")
            return
        }
        let zoomScale = scrollView.zoomScale
        let contentSize = CGSize(
            width: view.intrinsicContentSize.width * zoomScale,
            height: view.intrinsicContentSize.height * zoomScale)
        scrollView.contentSize = contentSize
    }

    class Coordinator: NSObject, UIScrollViewDelegate,
        UIGestureRecognizerDelegate
    {
        weak var scrollView: UIScrollView?

        private var displayLink: CADisplayLink?
        private var autoScrollDirection: AutoScrollDirection = .none

        // Some margin threshold (in points) from the edge:
        private let horizontalThreshold: CGFloat = 1000
        private let verticalThreshold: CGFloat = 500

        enum AutoScrollDirection {
            case none
            case left
            case right
            case up
            case down
        }

        var hostingController: UIHostingController<Content>
        var canvasViewModel: CanvasPageViewModel
        var appModel: AppModel

        private var idleTimer: Timer?
        private var unreadTimers: [String: Timer] = [:]
        private var checkTimer: Timer?

        init(
            hostingController: UIHostingController<Content>,
            canvasViewModel: CanvasPageViewModel, appModel: AppModel
        ) {
            self.hostingController = hostingController
            self.canvasViewModel = canvasViewModel
            self.appModel = appModel
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }

        private func resetIdleTimer(_ scrollView: UIScrollView) {
            idleTimer?.invalidate()
            idleTimer = Timer.scheduledTimer(
                withTimeInterval: 2.0, repeats: false
            ) { [weak self] _ in
                if self?.canvasViewModel.canvasMode == .normal {
                    self?.autoCenterOnCursor(scrollView)
                }
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            updateCenter(for: scrollView)
            resetIdleTimer(scrollView)
            checkVisibleBounds(scrollView)
            let rect = getUnscaledVisibleRect(scrollView: scrollView)
            canvasViewModel.visibleRectInCanvas = rect
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateContentSize(for: scrollView)
            updateCenter(for: scrollView)
            resetIdleTimer(scrollView)
            checkVisibleBounds(scrollView)

            let rect = getUnscaledVisibleRect(scrollView: scrollView)
            canvasViewModel.zoomScale = scrollView.zoomScale
            canvasViewModel.visibleRectInCanvas = rect
        }

        private func checkVisibleBounds(_ scrollView: UIScrollView) {
            let visibleOrigin = scrollView.contentOffset
            let visibleSize = scrollView.bounds.size
            let visibleRect = CGRect(origin: visibleOrigin, size: visibleSize)

            // 2) For each unread widget, see if it's visible
            for widgetId in canvasViewModel.unreadWidgets {
                guard
                    let widget = canvasViewModel.canvasWidgets.first(where: {
                        $0.id.uuidString == widgetId
                    })
                else { continue }

                let widgetRect = CGRect(
                    x: widget.x ?? 0,
                    y: widget.y ?? 0,
                    width: widget.width,
                    height: widget.height
                )

                // Check if widgetRect intersects the visibleRect
                if visibleRect.intersects(widgetRect) {
                    scheduleReadTimer(for: widgetId)
                } else {
                    cancelReadTimer(for: widgetId)
                }
            }
        }

        private func scheduleReadTimer(for widgetId: String) {
            // If we already have a timer for this widget, do nothing
            if unreadTimers[widgetId] != nil { return }

            // Create a 3-second timer
            let timer = Timer.scheduledTimer(
                withTimeInterval: 1.0, repeats: false
            ) { [weak self] _ in
                guard let self = self else { return }
                self.markWidgetAsRead(widgetId)
            }
            unreadTimers[widgetId] = timer
        }

        private func cancelReadTimer(for widgetId: String) {
            if let timer = unreadTimers[widgetId] {
                timer.invalidate()
                unreadTimers.removeValue(forKey: widgetId)
            }
        }

        private func markWidgetAsRead(_ widgetId: String) {
            // 1) Invalidate and remove the timer (just in case)
            unreadTimers[widgetId]?.invalidate()
            unreadTimers.removeValue(forKey: widgetId)

            // 2) Update your local `unreadWidgets` in the ViewModel
            if let index = canvasViewModel.unreadWidgets.firstIndex(
                of: widgetId)
            {
                canvasViewModel.unreadWidgets.remove(at: index)
            }

            // 3) Do your Firebase call to mark it as read
            Task {
                await removeWidgetFromUnreads(widgetId: widgetId)
            }
        }

        /// Example of removing that widget from the "unreads" array in Firestore
        private func removeWidgetFromUnreads(widgetId: String) async {
            guard let userId = appModel.user?.userId else { return }
            let spaceId = canvasViewModel.spaceId
            do {
                try await Firestore.firestore().collection("spaces")
                    .document(spaceId)
                    .collection("unreads")
                    .document(userId)
                    .updateData([
                        "widgets": FieldValue.arrayRemove([widgetId]),
                        "count": FieldValue.increment(Int64(-1)),
                    ])
            } catch {
                print("Failed to remove widget from unreads: \(error)")
            }
        }

        private func updateContentSize(for scrollView: UIScrollView) {
            guard let view = scrollView.subviews.first else {
                print("ZoomableScrollView: no subview")
                return
            }
            let zoomScale = scrollView.zoomScale
            let contentSize = CGSize(
                width: view.intrinsicContentSize.width * zoomScale,
                height: view.intrinsicContentSize.height * zoomScale)
            scrollView.contentSize = contentSize
        }

        // In ZoomableScrollView.Coordinator
        func scrollToWidget(_ widget: CanvasWidget) {
            // 1) Grab the scrollView from our stored reference
            guard let scrollView = self.scrollView else { return }

            // 2) The rest of your logic is unchanged:
            guard let hostedView = scrollView.subviews.first else { return }

            let unscaledWidth = hostedView.intrinsicContentSize.width
            let unscaledHeight = hostedView.intrinsicContentSize.height

            let widgetCenterX = (widget.x ?? 0) + widget.width / 2
            let widgetCenterY = (widget.y ?? 0) + widget.height / 2

            let zoomedX = widgetCenterX * scrollView.zoomScale
            let zoomedY = widgetCenterY * scrollView.zoomScale

            let offsetX = zoomedX - (scrollView.bounds.width / 2)
            let offsetY = zoomedY - (scrollView.bounds.height / 2)

            let maxOffsetX =
                scrollView.contentSize.width - scrollView.bounds.width
            let maxOffsetY =
                scrollView.contentSize.height - scrollView.bounds.height

            let clampedX = max(0, min(offsetX, maxOffsetX))
            let clampedY = max(0, min(offsetY, maxOffsetY))

            scrollView.setContentOffset(
                CGPoint(x: clampedX, y: clampedY), animated: true)
        }

        private func autoCenterOnCursor(_ scrollView: UIScrollView) {
            // Only auto-center in .normal mode
            guard canvasViewModel.canvasMode == .normal else { return }

            // 1) The cursor in “unscaled subview coordinates”
            let cursorPoint = canvasViewModel.canvasPageCursor

            // 2) Find the nearest widget
            guard let widget = nearestWidget(to: cursorPoint) else {
                return
            }

            // 3) Reuse your “scrollToWidget(_:)” method
            scrollToWidget(widget)
        }

        func updateCenter(for scrollView: UIScrollView) {
            guard let hostedView = scrollView.subviews.first,
                hostedView.intrinsicContentSize.width > 0,
                hostedView.intrinsicContentSize.height > 0
            else {
                print("updateCenter: subview not ready yet")
                return
            }

            // 1) The center in the zoomed coordinate system:
            let zoomedCenterX =
                scrollView.contentOffset.x + (scrollView.bounds.width / 2)
            let zoomedCenterY =
                scrollView.contentOffset.y + (scrollView.bounds.height / 2)

            // 2) Convert to unscaled coordinates by dividing out zoomScale:
            var unscaledCenterX = zoomedCenterX / scrollView.zoomScale
            var unscaledCenterY = zoomedCenterY / scrollView.zoomScale

            canvasViewModel.canvasPageCursor = CGPoint(
                x: unscaledCenterX, y: unscaledCenterY)

            canvasViewModel.widgetCursor = CGPoint(
                x: roundToTile(number: unscaledCenterX),
                y: roundToTile(number: unscaledCenterY)
            )

            // 3) If you want (0,0) to be the subview’s center:
            let unscaledWidth = hostedView.intrinsicContentSize.width
            let unscaledHeight = hostedView.intrinsicContentSize.height

            unscaledCenterX -= unscaledWidth / 2
            unscaledCenterY -= unscaledHeight / 2

            // 4) Assign to your ViewModel
            let centerPoint = CGPoint(
                x: roundToTile(number: unscaledCenterX),
                y: roundToTile(number: unscaledCenterY))
            canvasViewModel.scrollViewCursor = centerPoint
        }

        func getUnscaledVisibleRect(scrollView: UIScrollView) -> CGRect {
            let scale = scrollView.zoomScale

            let x = scrollView.contentOffset.x / scale
            let y = scrollView.contentOffset.y / scale
            let width = scrollView.bounds.size.width / scale
            let height = scrollView.bounds.size.height / scale

            return CGRect(x: x, y: y, width: width, height: height)
        }

//        @objc func handleEdgePan(_ gesture: UIPanGestureRecognizer) {
//            guard let scrollView = scrollView else { return }
//
//            if canvasViewModel.canvasMode != .dragging { return }
//            let location = gesture.location(in: scrollView)
//
//            switch gesture.state {
//            case .began, .changed:
//                // Figure out which edge we’re nearest to:
//                autoScrollDirection = calculateDirectionIfNearEdge(
//                    location: location,
//                    scrollView: scrollView
//                )
//
//                if autoScrollDirection != .none {
//                    // If not already auto-scrolling, start it
//                    startAutoScroll()
//                } else {
//                    // If we’ve moved away from the edge, stop auto-scrolling
//                    stopAutoScroll()
//                }
//
//            case .ended, .cancelled, .failed:
//                // User lifted finger or gesture ended—stop auto-scrolling
//                stopAutoScroll()
//
//            default:
//                break
//            }
//        }

        private func calculateDirectionIfNearEdge(
            location: CGPoint,
            scrollView: UIScrollView
        ) -> AutoScrollDirection {
            // Convert local point to the scrollView’s coordinate space
            // For example, if near left edge:
            if location.x < horizontalThreshold {
                return .left
            }
            // if near right edge:
            if location.x > scrollView.bounds.width - horizontalThreshold {
                return .right
            }
            // if near top edge:
            if location.y < verticalThreshold {
                return .up
            }
            // if near bottom edge:
            if location.y > scrollView.bounds.height - verticalThreshold {
                return .down
            }

            return .none
        }

        private func startAutoScroll() {
            guard displayLink == nil else { return }
            displayLink = CADisplayLink(
                target: self, selector: #selector(handleAutoScroll))
            displayLink?.add(to: .main, forMode: .common)
        }

        private func stopAutoScroll() {
            displayLink?.invalidate()
            displayLink = nil
            autoScrollDirection = .none
        }

        @objc private func handleAutoScroll() {
            guard let scrollView = scrollView else { return }

            // Adjust this speed as needed
            let scrollSpeed: CGFloat = 8

            var offset = scrollView.contentOffset

            switch autoScrollDirection {
            case .left:
                offset.x -= scrollSpeed
                offset.x = max(offset.x, 0)  // prevent overscrolling
            case .right:
                offset.x += scrollSpeed
                let maxOffsetX =
                    scrollView.contentSize.width - scrollView.bounds.width
                offset.x = min(offset.x, maxOffsetX)
            case .up:
                offset.y -= scrollSpeed
                offset.y = max(offset.y, 0)
            case .down:
                offset.y += scrollSpeed
                let maxOffsetY =
                    scrollView.contentSize.height - scrollView.bounds.height
                offset.y = min(offset.y, maxOffsetY)
            case .none:
                return
            }

            // Update the scrollView’s offset (no animation).
            scrollView.setContentOffset(offset, animated: false)
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer:
                UIGestureRecognizer
        ) -> Bool {
            return true
        }

        private func nearestWidget(to point: CGPoint) -> CanvasWidget? {
            // If you have no widgets, early-exit
            guard !canvasViewModel.canvasWidgets.isEmpty else { return nil }

            var closestWidget: CanvasWidget?
            var smallestDistance = CGFloat.infinity

            for widget in canvasViewModel.canvasWidgets {
                // Compute each widget’s center:
                let widgetCenter = CGPoint(
                    x: (widget.x ?? 0) + widget.width / 2,
                    y: (widget.y ?? 0) + widget.height / 2
                )

                let dx = point.x - widgetCenter.x
                let dy = point.y - widgetCenter.y
                let distanceSquared = dx * dx + dy * dy

                if distanceSquared < smallestDistance {
                    smallestDistance = distanceSquared
                    closestWidget = widget
                }
            }

            return closestWidget
        }
        
        func startPeriodicCheck() {
            // Invalidate if somehow still running
            checkTimer?.invalidate()

            checkTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                guard let self = self, let scrollView = self.scrollView else { return }
                self.checkVisibleBounds(scrollView)
            }

            // If you want the timer to run while the user is interacting with the scrollview,
            // you may need to add it to the run loop in .common modes:
            // RunLoop.main.add(checkTimer!, forMode: .common)
        }

        func stopPeriodicCheck() {
            checkTimer?.invalidate()
            checkTimer = nil
        }

        deinit {
            // In case the Coordinator is deallocated, clean up the timer
            stopPeriodicCheck()
        }
    }
}

protocol ZoomCoordinatorProtocol: AnyObject {
    func scrollToWidget(_ widget: CanvasWidget)
}

extension ZoomableScrollView.Coordinator: ZoomCoordinatorProtocol {
    // already has scrollToWidget, so we conform
}

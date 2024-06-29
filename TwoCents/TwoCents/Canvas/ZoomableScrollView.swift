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
    @Binding var toolPickerActive: Bool

    init(toolPickerActive: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._toolPickerActive = toolPickerActive
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 0.5
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = !toolPickerActive

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)

        // Add width and height constraints for the hosted view
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.isScrollEnabled = !toolPickerActive
        context.coordinator.hostingController.rootView = self.content
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
        updateContentSize(for: uiView)
        if uiView.contentOffset == .zero {
            let initialOffsetX = (uiView.contentSize.width - uiView.bounds.width) / 2
            let initialOffsetY = (uiView.contentSize.height - uiView.bounds.height) / 2
            uiView.contentOffset = CGPoint(x: initialOffsetX, y: initialOffsetY)
        }
    }

    private func updateContentSize(for scrollView: UIScrollView) {
        guard let view = scrollView.subviews.first else { return }
        let zoomScale = scrollView.zoomScale
        let contentSize = CGSize(width: view.intrinsicContentSize.width * zoomScale, height: view.intrinsicContentSize.height * zoomScale)
               scrollView.contentSize = contentSize
        scrollView.contentSize = contentSize
    }


    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateContentSize(for: scrollView)
        }

        private func updateContentSize(for scrollView: UIScrollView) {
            guard let view = scrollView.subviews.first else { return }
            let zoomScale = scrollView.zoomScale
            let contentSize = CGSize(width: view.intrinsicContentSize.width * zoomScale, height: view.intrinsicContentSize.height * zoomScale)
            scrollView.contentSize = contentSize
        }

    }
}

//
//  LinkWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/3.
//

import Foundation
import LinkPresentation
import SwiftUI

struct LinkWidget: WidgetView {

    let widget: CanvasWidget

    init(widget: CanvasWidget) {
        assert(widget.media == .link)
        self.widget = widget

    }

    var body: some View {
        VStack {
            LinkView(widget: widget)
                .frame(width: widget.width, height: widget.height)
        }
    }
}

struct LinkView: UIViewRepresentable {

    let url: URL
    let width: CGFloat
    let height: CGFloat

    init(widget: CanvasWidget) {
        //This is a requirement for all link widgets if not then it's broken to begin with -Eric
        self.url = widget.mediaURL!
        self.width = widget.width
        self.height = widget.height
    }

    init(url: URL) {
        self.url = url
        self.width = TILE_SIZE
        self.height = TILE_SIZE
    }

    func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView(url: url)
        view.translatesAutoresizingMaskIntoConstraints = false
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            guard let metadata = metadata, error == nil else {
                return
            }
            DispatchQueue.main.async {
                metadata.title = ""
                view.metadata = metadata
            }
        }
        return view
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {
        DispatchQueue.main.async {
            NSLayoutConstraint.deactivate(uiView.constraints)
            NSLayoutConstraint.activate([
                uiView.widthAnchor.constraint(equalToConstant: width),
                uiView.heightAnchor.constraint(equalToConstant: height),
            ])
            uiView.invalidateIntrinsicContentSize()
        }
    }

    private func hideTextSubviews(in view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                label.isHidden = true  // Hide the label
            } else {
                hideTextSubviews(in: subview)  // Recursively hide labels in subviews
            }
        }
    }
}

#Preview {
    LinkWidget(
        widget: CanvasWidget(
            width: .infinity, height: .infinity, x: 0, y: 0, borderColor: .red,
            userId: "jisookim", media: .link,
            mediaURL: URL(string: "https://www.twocentsapp.com/"),
            widgetName: "Text", widgetDescription: "A bar is a bar",
            textString: "Fruits can't even see so how my Apple Watch"))
}

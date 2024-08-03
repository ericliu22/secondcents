//
//  LinkWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/3.
//

import Foundation
import SwiftUI
import LinkPresentation

struct LinkWidget: WidgetView {
    
    let widget: CanvasWidget
    
    init(widget: CanvasWidget) {
        assert(widget.media == .link)
        self.widget = widget
        
    }
    
    var body: some View {
        VStack {
            LinkView(url: widget.mediaURL!)
                .frame(width: TILE_SIZE, height: TILE_SIZE)
                .padding()
        }
    }
}

struct LinkView: UIViewRepresentable {
    
    let url: URL
    let width: CGFloat = TILE_SIZE
    let height: CGFloat = TILE_SIZE
    
    init(url: URL) {
        self.url = url
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
               view.metadata = metadata
           }
        }
        return view
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {
        NSLayoutConstraint.deactivate(uiView.constraints)
        NSLayoutConstraint.activate([
            uiView.widthAnchor.constraint(equalToConstant: width),
            uiView.heightAnchor.constraint(equalToConstant: height)
        ])
        uiView.invalidateIntrinsicContentSize()
    }
}

#Preview{
    LinkWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, x: 0, y:0, borderColor: .red, userId: "jisookim", media: .link, mediaURL: URL(string: "https://www.twocentsapp.com/"), widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
}

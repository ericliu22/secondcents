//
//  WidgetSizeView.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/10/6.
//
import SwiftUI

@Observable @MainActor
final class WidgetSizeModel {
    
    var widgets: [CanvasWidget] = []
    let widget: CanvasWidget
    let sizes: [(CGFloat, CGFloat)] = [(TILE_SIZE, TILE_SIZE), getMultipliedSize(widthMultiplier: 1, heightMultiplier: 2), getMultipliedSize(widthMultiplier: 2, heightMultiplier: 1), getMultipliedSize(widthMultiplier: 2, heightMultiplier: 2)]
    
    init(widget: CanvasWidget) {
        self.widget = widget
        generateWidgets(widget: widget)
    }
    
    func generateWidgets(widget: CanvasWidget) {
        for size in sizes {
            let (width, height) = size
            var newWidget = widget
            newWidget.width = width
            newWidget.height = height
            widgets.append(newWidget)
        }
    }
}

struct WidgetSizeView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: WidgetSizeModel
    
    let widget: CanvasWidget
    let spaceId: String
    
    init(widget: CanvasWidget, spaceId: String) {
        self.widget = widget
        self.spaceId = spaceId
        viewModel = WidgetSizeModel(widget: widget)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.widgets, id: \.id){ sizedWidget in
                    MediaView(widget: sizedWidget, spaceId: spaceId)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
                        .cornerRadius(CORNER_RADIUS)
                        .frame(
                            width: widget.width,
                            height: widget.height
                        )
                        .disabled(false)
                        .onTapGesture {
                            print("Hello")
                        }
                }
            }
        }
    }
    
}

/*
struct WidgetSize_Previews: PreviewProvider {
    
    static var previews: some View {
        WidgetSizeView(widget: , spaceId: "883430EA-2C4B-44BE-B48E-E42798CA6249")
    }
}

*/  

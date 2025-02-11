//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct TextWidget: WidgetView {
    
    //@TODO: Clean all of this up
    //1. Put the state variables in VM
    //2. Put functions in VM
    @State private var isPresented: Bool = false
    @State var textString: String
    @State private var userColor: Color = .gray
    @State private var viewModel = TextWidgetViewModel()
    @State private var textListener: ListenerRegistration?
    @Environment(CanvasPageViewModel.self) var canvasViewModel

    var widget: CanvasWidget // Assuming CanvasWidget is a defined type
    private var spaceId: String
    
    
    init (widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .text)
        self.widget = widget
        self.spaceId = spaceId
        self.textString = widget.textString ?? ""
    }
    
    
    var body: some View {
        Text(self.textString)
            .multilineTextAlignment(.leading)
            .font(.custom("LuckiestGuy-Regular", size: 24, relativeTo: .headline))
            .padding(5)
            .minimumScaleFactor(0.8)
            .frame(width: widget.width, height: widget.height)
            .background(.ultraThickMaterial)
            .background(userColor)
            .foregroundColor(userColor)
            .task {
                guard let userColor = canvasViewModel.members[id: widget.userId]?.userColor else {
                    return
                }
                withAnimation{
                    self.userColor = Color.fromString(name: userColor)
                }
                fetchText()
                
            }
            .onDisappear {
                textListener?.remove()
            }
    }
    
    //plswork
    func fetchText() {
        textListener = spaceReference(spaceId: spaceId)
            .collection("widgets")
            .document(widget.id.uuidString)
            .addSnapshotListener{ documentSnapshot, error in
                if let error = error {
                            print("Error fetching text: \(error)")
                            return
                        }
                        
                        guard let document = documentSnapshot else {
                            print("Document does not exist.")
                            return
                        }
                        
                        // Fetch and update the widget's textString field
                        if let textString = document.get("textString") as? String {
                            DispatchQueue.main.async {
                                self.textString = textString
                            }
                        }
            }
    }
}

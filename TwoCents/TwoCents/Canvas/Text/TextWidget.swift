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
    
    @State private var isPresented: Bool = false
    
    var widget: CanvasWidget // Assuming CanvasWidget is a defined type
    private var spaceId: String
    
    @State var textString: String
    
    init (widget: CanvasWidget, spaceId: String) {
        assert(widget.media == .text)
        self.widget = widget
        self.spaceId = spaceId
        self.textString = widget.textString ?? ""
    }
    @StateObject private var viewModel = TextWidgetViewModel()
    
    @State private var userColor: Color = .gray
    
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
                try? await viewModel.loadUser(userId: widget.userId)
                withAnimation{
                    self.userColor = viewModel.getUserColor(userColor:viewModel.user?.userColor ?? "")
                }
                fetchText()
                
            }
    }
    
    //plswork
    func fetchText() {
        Firestore.firestore().collection("spaces")
            .document(spaceId)
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

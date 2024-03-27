//
//  PencilKit.swift
//  TwoCents
//
//  Created by Eric Liu on 1/18/24.
//

import SwiftUI
import PencilKit

struct DrawingCanvas: UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var toolPickerActive: Bool
    @Binding var toolPicker: PKToolPicker
    var spaceId: String
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingGestureRecognizer.addTarget(context.coordinator, action: #selector(context.coordinator.drawing(_:)))
        canvas.contentSize = CGSize(width: FRAME_SIZE, height: FRAME_SIZE)
        canvas.drawingPolicy = .anyInput
        canvas.minimumZoomScale = MIN_ZOOM
        canvas.maximumZoomScale = MAX_ZOOM
        canvas.backgroundColor = .clear
        canvas.contentInset = UIEdgeInsets(top: 280, left: 400, bottom: 280, right: 400)
        //        canvas.backgroundColor = .red
        canvas.contentMode = .center
        canvas.scrollsToTop = false
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func showToolPicker() {
        //          toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
        canvas.drawingGestureRecognizer.isEnabled = toolPickerActive
        
    }
    
    func pushDrawing() async {
        
        
        
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator(spaceId: spaceId, canvas: canvas)
        }
        
        class Coordinator: NSObject {
            
            var canvas: PKCanvasView
            var spaceId: String
            
            init(spaceId: String, canvas: PKCanvasView) {
                self.spaceId = spaceId
                self.canvas = canvas
            }
            
            @objc func drawing(_ gestureRecognizer: UIGestureRecognizer) {
                if gestureRecognizer.state == .ended {
                    print("Drawing ended")
                    Task {
                        do {
                            try await db.collection("spaces").document(spaceId).updateData([
                                "drawing": canvas.drawing.dataRepresentation(),
                            ])
                            print("Document successfully written!")
                        } catch {
                            print("Error writing document: \(error)")
                        }
                    }
                }
            }
        }
}

extension PKStroke {
    
    public func isExpired() -> Bool {
        let currentTime = Date()
        return currentTime.timeIntervalSince(self.path.creationDate) > 30
    }
}

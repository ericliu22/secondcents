//
//  PencilKit.swift
//  TwoCents
//
//  Created by Eric Liu on 1/18/24.
//

import SwiftUI
import PencilKit

struct DrawingCanvas: UIViewRepresentable {
    
    @Environment(CanvasPageViewModel.self) var canvasViewModel
    @State var toolPicker: PKToolPicker = PKToolPicker()
    @State var canvas: PKCanvasView = PKCanvasView()
    var spaceId: String
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingGestureRecognizer.addTarget(context.coordinator, action: #selector(context.coordinator.drawing(_:)))
        context.coordinator.startTimer()
        canvas.contentSize = CGSize(width: FRAME_SIZE, height: FRAME_SIZE)
        canvas.drawingPolicy = .anyInput
        canvas.minimumZoomScale = MIN_ZOOM
        canvas.maximumZoomScale = MAX_ZOOM
        canvas.backgroundColor = .clear
        canvas.contentInset = UIEdgeInsets(top: 280, left: 400, bottom: 280, right: 400)
        canvas.contentMode = .center
        canvas.scrollsToTop = false
        canvas.becomeFirstResponder()
        toolPicker.addObserver(canvas)
        attachDrawingListener()
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        canvas.drawingGestureRecognizer.isEnabled = canvasViewModel.isDrawing
        toolPicker.setVisible(canvasViewModel.isDrawing, forFirstResponder: canvas)
    }
    
    func attachDrawingListener() {
        db.collection("spaces").document(spaceId).addSnapshotListener { documentSnapshot, error in
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard document.exists else {
                print("Document doesn't exist")
                return
            }
            
            guard let data = document.data() else {
                print("Empty document")
                return
            }
            
            if let drawingAccess = data["drawing"] as? Data {
                let databaseDrawing = try! PKDrawingReference(data: drawingAccess)
                let newDrawing = databaseDrawing.appending(canvas.drawing)
                canvas.drawing = newDrawing
            } else {
                print("No database drawing")
            }
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.stopTimer() // Stop the timer when the view is dismantled
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(spaceId: spaceId, canvas: canvas)
    }
    
    class Coordinator: NSObject {
        
        var canvas: PKCanvasView
        var spaceId: String
        var timer: Timer?
        
        init(spaceId: String, canvas: PKCanvasView) {
            self.spaceId = spaceId
            self.canvas = canvas
        }
        
        func removeExpiredStrokes() {
            var changed: Bool = false
            let strokes = canvas.drawing.strokes.filter { stroke in
                if (stroke.isExpired()) {
                    changed = true
                }
                //include only if not expired
                return !stroke.isExpired()
            }
            if changed {
                
                canvas.drawing = PKDrawing(strokes: strokes)
                canvas.upload(spaceId: spaceId)
                
            }
        }
        
        func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                self.removeExpiredStrokes()
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        @objc func drawing(_ gestureRecognizer: UIGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                canvas.upload(spaceId: spaceId)
                
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

extension PKCanvasView {
    public func upload(spaceId: String) {
        Task {
            do {
                try await db.collection("spaces").document(spaceId).updateData([
                    "drawing": self.drawing.dataRepresentation(),
                ])
            } catch {
                print("Error uploading canvas: \(error)")
            }
        }
    }
}

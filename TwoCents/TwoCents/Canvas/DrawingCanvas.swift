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

    func makeUIView(context: Context) -> PKCanvasView {
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
    
}

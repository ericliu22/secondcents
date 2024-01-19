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
    
    let toolPicker = PKToolPicker()
    

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.contentSize = CGSize(width: FRAME_SIZE, height: FRAME_SIZE)
        canvas.drawingPolicy = .anyInput
        canvas.minimumZoomScale = MIN_ZOOM
        canvas.maximumZoomScale = MAX_ZOOM
        canvas.backgroundColor = .clear
        canvas.contentInset = UIEdgeInsets(top: 280, left: 400, bottom: 280, right: 400)
        canvas.contentMode = .center
        canvas.scrollsToTop = false
        canvas.becomeFirstResponder()
        showToolPicker()
        
        
        return canvas
    }
    
    func showToolPicker() {
          toolPicker.setVisible(true, forFirstResponder: canvas)
        
        
          toolPicker.addObserver(canvas)
          canvas.becomeFirstResponder()
        }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
        toolPicker.setVisible(toolPickerActive, forFirstResponder: canvas)
        if toolPickerActive == false {
            self.canvas.drawingGestureRecognizer.isEnabled = false
        } else {
            self.canvas.drawingGestureRecognizer.isEnabled = true
        }

        print("TOOLPICKERACTIVE \(toolPickerActive)")
        print("i changed")
        
    }
}

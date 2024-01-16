//
//  PencilKitPractice.swift
//  TwoCents
//
//  Created by Enzo Tanjutco on 1/9/24.
//

import SwiftUI
import PencilKit

struct PencilKitPractice: View {
    var body: some View {
        Home()
    }
}

#Preview {
    PencilKitPractice()
}

struct Home: View {
    
    @State var canvas = PKCanvasView()
    @State var isDraw = true
    // default is pen...
    
    @State private var toolPickerIsActive = false
    @State private var canvasIsVisible = false
    
    
    
    var body: some View{
        NavigationView{
            // Drawing View
            
            
                ZStack{
                    
//                    Button(action: {
//                        toolPickerIsActive.toggle()
//                    }, label: {
//                        Text("button beneath canvas")
//                    })
                    
        
                    
                    DrawingView(canvas: $canvas, isDraw: $isDraw, toolPickerIsActive: $toolPickerIsActive)
                        .allowsHitTesting(toolPickerIsActive)

            }
                .navigationTitle("Drawing")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                                        Button(action: {
                                            toolPickerIsActive.toggle()
                                        }, label: {
                                            Text("toggle toolpicker")
                                        }))
        }
        
    }
    
}

struct DrawingView : UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var isDraw: Bool
    @Binding var toolPickerIsActive: Bool
    
    let toolPicker = PKToolPicker()
    

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.contentSize = CGSize(width: 1200, height: 1500)
        canvas.drawingPolicy = .anyInput
        canvas.minimumZoomScale = 0.1
        canvas.maximumZoomScale = 4.0
//        canvas.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
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
        
        toolPicker.setVisible(toolPickerIsActive, forFirstResponder: canvas)

        print("i changed")
        
    }
}

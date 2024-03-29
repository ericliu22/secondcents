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
    
    @State var tapped = false
    
    
    var body: some View{
        NavigationView{
            // Drawing View
            
            
                ZStack{
                    
//                    Button(action: {
//                        toolPickerIsActive.toggle()
//                    }, label: {
//                        Text("button beneath canvas")
//                    })
                    
                    Circle()
                        .onTapGesture {
                            tapped.toggle()

                        }
                        .frame(height: tapped ? 100 : 50)
//                        .foregroundColor(tapped ? .red : .gray)
        
                    
                    DrawingView(canvas: $canvas, isDraw: $isDraw, toolPickerIsActive: $toolPickerIsActive)
                        .allowsHitTesting(toolPickerIsActive)
                        .onTapGesture {
                            if toolPickerIsActive == false{
                            self.canvas.drawingGestureRecognizer.isEnabled = false
                                    } 
                            else {
                            self.canvas.drawingGestureRecognizer.isEnabled = true
                                    }
                        }

            }
                .navigationTitle("Drawing")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                                        Button(action: {
                                            toolPickerIsActive.toggle()
                    
                                        }, label: {
                                            Text(toolPickerIsActive ? "TOOLPICKER: ON" : "TOOLPICKER: OFF")
                                        }))
        }
        
    }
    
}

struct DrawingView : UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var isDraw: Bool
    @Binding var toolPickerIsActive: Bool
    
    @State private var hasTimeElapsed = false
    
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
        
        
                
        

//        canvas.becomeFirstResponder()

        
        return canvas
    }
    
 
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
        if !toolPickerIsActive { 
            
            return }
//        toolPicker.setVisible(toolPickerIsActive, forFirstResponder: canvas)
        
        
        
        canvas.isUserInteractionEnabled = toolPickerIsActive


        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()

        toolPicker.setVisible(toolPickerIsActive, forFirstResponder: canvas)
        
        if canvas.drawing.strokes.isEmpty == false {
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                
                canvas.drawing.strokes.removeAll()
                print(canvas.drawing.strokes)
            }
        }

        
        
    }
 
}


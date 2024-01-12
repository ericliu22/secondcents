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
    
    var body: some View{
        NavigationView{
            // Drawing View
            
            DrawingView(canvas: $canvas, isDraw: $isDraw)
                .navigationTitle("Drawing")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    
                    SaveImage()
                    
                }, label: {
                    
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.title)
                }), trailing: HStack(spacing: 15){
//                    
//                    Button(action: {
//                        
//                        // erase tool
//                        
//                        isDraw.toggle()
//                    }) {
//                        
//                        Image(systemName: "pencil.slash")
//                    }
                    
                })
        }
    }
    
    func SaveImage(){
        let image = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1)
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}

struct DrawingView : UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var isDraw: Bool
    
//    let ink = PKInkingTool(.pencil, color: .black)
//    
//    let eraser = PKEraserTool(.bitmap)
    
    let toolPicker = PKToolPicker()
    
    let drawing = PKDrawing()
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvas.drawingPolicy = .anyInput
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        canvas.drawing = drawing
        
//        canvas.tool = isDraw ? ink : eraser
        
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
        //updating tool whenever main view updates
        
//        uiView.tool = isDraw ? ink : eraser
        
        
    }
}

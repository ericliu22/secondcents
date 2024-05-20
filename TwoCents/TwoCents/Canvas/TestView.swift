import SwiftUI

struct ContentView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var cumulativeScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Zoomable and Draggable Canvas")
                    .font(.headline)
                CanvasView(scale: $scale, offset: $offset, cumulativeScale: $cumulativeScale)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                    .border(Color.gray)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.offset = CGSize(
                                    width: self.lastOffset.width + value.translation.width,
                                    height: self.lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { value in
                                self.lastOffset = self.offset
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                self.scale = self.cumulativeScale * value
                            }
                            .onEnded { value in
                                self.cumulativeScale *= value
                            }
                    )
            }
        }
    }
}

struct CanvasView: View {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var cumulativeScale: CGFloat

    var body: some View {
        ZStack {
            // Your canvas content goes here
            Color.white

            // Example content: A grid of rectangles
            ForEach(0..<10) { i in
                ForEach(0..<10) { j in
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .position(
                            x: CGFloat(i) * 60 + 30,
                            y: CGFloat(j) * 60 + 30
                        )
                }
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .clipped() // Ensure the content does not overflow
        .animation(.spring()) // Optional: Add some animation
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

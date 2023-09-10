//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color: Color = .red
    var lineWidth: Double = 10.0
}
struct CanvasPage: View {
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                print(line.points)
            }
            
        }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
            let newPoint = value.location
            currentLine.points.append(newPoint)
            self.lines.append(currentLine)
        })
            .onEnded({value in
                self.lines.append(currentLine)
                self.currentLine = Line(points: [])
            })
        )
        .frame(minWidth: 400, minHeight: 400)
    }
}

struct CanvasPage_Previews: PreviewProvider {
    static var previews: some View {
        CanvasPage()
    }
}

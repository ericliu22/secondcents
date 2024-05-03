//
//  TestView.swift
//  TwoCents
//
//  Created by jonathan on 5/1/24.
//

import SwiftUI


import SwiftUI


struct TestView: View {
    @State var screenW = 0.0
    @State var scale = 1.0
    @State var lastScale = 0.0
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Mily")
                    .font(.largeTitle)
                Image("jennie kim")
                    .resizable()
                    .scaleEffect(scale)
                    .offset(offset)
                    .scaledToFill()
                    .frame(width: screenW, height: screenW)
                    .clipped()
                    .gesture(
                        MagnificationGesture(minimumScaleDelta: 0)
                            .onChanged({ value in
                                withAnimation(.interactiveSpring()) {
                                    scale = handleScaleChange(value)
                                }
                            })
                            .onEnded({ _ in
                                lastScale = scale
                            })
                            .simultaneously(
                                with: DragGesture(minimumDistance: 0)
                                    .onChanged({ value in
                                        withAnimation(.interactiveSpring()) {
                                            offset = handleOffsetChange(value.translation)
                                        }
                                    })
                                    .onEnded({ _ in
                                        lastOffset = offset
                                    })

                            )
                    )
            }
            .onAppear {
                screenW = geometry.size.width
            }
        }
    }

    private func handleScaleChange(_ zoom: CGFloat) -> CGFloat {
        max ( 0.1, lastScale + zoom - (lastScale == 0 ? 0 : 1))
        
        
    }

    private func handleOffsetChange(_ offset: CGSize) -> CGSize {
        var newOffset: CGSize = .zero

        newOffset.width = offset.width + lastOffset.width
        newOffset.height = offset.height + lastOffset.height

        return newOffset
    }
}

#Preview {
    TestView()
}

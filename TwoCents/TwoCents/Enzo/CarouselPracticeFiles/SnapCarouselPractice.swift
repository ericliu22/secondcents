//
//  SnapCarouselPractice.swift
//  TwoCents
//
//  Created by Enzo Tanjutco on 10/6/23.
//

import SwiftUI

struct SnapCarouselPractice<Content: View, T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    
    // Properties...
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, index: Binding<Int>, items: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    //Offset...
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader{proxy in
            
            //Setting correct width
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustmentWidth = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing){
//                ForEach(list){item in
//                    content(item)
//                        .frame(width: proxy.size.width - trailingSpace)
//
//                }
                
//                ZStack{
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: proxy.size.width - trailingSpace)
//                    NavigationLink {
//                        TestTest()
//                    } label: {
//                        Circle()
//                    }
//                }
//                ZStack{
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: proxy.size.width - trailingSpace)
//                    NavigationLink {
//                        TestTest()
//                    } label: {
//                        Circle()
//                    }
//                }
//                ZStack{
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: proxy.size.width - trailingSpace)
//                    NavigationLink {
//                        TestTest()
//                    } label: {
//                        Circle()
//                    }
//                }
//                ZStack{
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: proxy.size.width - trailingSpace)
//                    NavigationLink {
//                        TestTest()
//                    } label: {
//                        Circle()
//                    }
//                }
                

                
                
            }
            .padding(.horizontal,spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustmentWidth: 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        
                        //were going to convert the translation into progress (0-1)
                        //and round the value
                        //based on shit
                        
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
//                        print("The list is: \(list)")
                        print("Round Index: \(roundIndex)")
                        print("current index : \(currentIndex)")

                        
                        //updating Index
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        
                        //were going to convert the translation into progress (0-1)
                        //and round the value
                        //based on shit
                        
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        //animating when offset = 0
        .animation(.easeInOut, value: offset == 0)
        
        
        
    }
}

struct SnapCarouselPractice_Previews: PreviewProvider {
    static var previews: some View {
        CarouselPractice()
    }
}

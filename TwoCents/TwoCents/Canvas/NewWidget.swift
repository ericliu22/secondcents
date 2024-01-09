//
//  NewWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/1/1.
//

import Foundation
import SwiftUI

struct NewWidget: View {
    
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    private let widgets: [String] = ["widget1", "widget2", "widget3", "widget4", "widget5", "widget6", "widget7", "widget8", "widget9", "widget10"]
    
    
    @Environment(\.dismiss) var dismissScreen
    
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        
        ZStack {
//            NavigationView {
//                VStack{
//                    ZStack{
//                        ForEach(0..<widgets.count, id: \.self) {index in
//                            Color.red
//                                .frame(width: 200, height: 200)
//                                .shadow(radius: 10, y: 10)
//                                .cornerRadius(25)
//                                .opacity(currentIndex == index ? 1.0: 0.5)
//                                .scaleEffect(currentIndex == index ? 1.2 : 0.8)
//                                .offset(x: CGFloat(index-currentIndex)*220 + dragOffset, y: 0)
//
//                        }
//                    }
//                    
//                
//                    
//                    .gesture(
//
//                        DragGesture()
//                         
//                            .onEnded({value in
//                                let threshold: CGFloat = 50
//                                if value.translation.width > threshold {
//                                    withAnimation{
//                                        currentIndex = max (0, currentIndex - 1)
//                                    }
//                                    
//                                } else if value.translation.width < -threshold {
//                                    withAnimation{
//                                        currentIndex = min(widgets.count - 1, currentIndex + 1)
//                                    }
//                                    
//                                }
//                              
//                                
//                                
//                                
//                            })
//                    )
//                    
//                }
//                .navigationTitle("Add a Widget 🙈")
//             
//                
//            }
//           
//            
            
            
            
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: 30)
                LazyVGrid(columns: columns, spacing: nil) {
                    ForEach(0..<widgets.count, id: \.self) {index in
                        
                        VStack{
                            Color.red
                            //                            .frame(width: 150, height: 150)
                            
                                .aspectRatio(1, contentMode: .fit)
                            
                                .shadow(radius: 20, y: 10)
                                .cornerRadius(20)
                            
                            
                            //                            .containerRelativeFrame(.vertical, count: 4, spacing: 20)
                            
                            
                            Text("Name")
                                .foregroundStyle(.primary)
                                .font(.headline)
                                .fontWeight(.regular)
                            
                            
                            Text("Description")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                                .fontWeight(.regular)
                            
                        }
                        .scrollTransition(.animated, axis: .vertical) { content, phase in
                            content
//                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                                .blur(radius: phase.isIdentity ? 0 : 3)
                            
                        }
                      
                    }
                }
                .scrollTargetLayout()
                
            }
           
//            .contentMargins(16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding()
            
  
            
            
            ZStack (alignment: .topLeading) {
                
                Color.clear
                    .edgesIgnoringSafeArea(.all)
                
                
                Button(action: {
                    dismissScreen()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(UIColor.label))
                        .font(.title2)
                        .padding()
                    
                })
                
                
            }
            
            
            
        }
    }
}

//
//struct Tile: View {
//
//    @State private var color: Color = .black
//    @State private var type: Media = .image
//
//    init(userColor: Color) {
//
//        self.color = userColor
//    }
//
//    var body: some View {
//        ZStack {
//            Text("Media")
//            RoundedRectangle(cornerRadius: CORNER_RADIUS)
//                .stroke(color, lineWidth: LINE_WIDTH)
//                .frame(width: TILE_SIZE, height: TILE_SIZE)
//        }
//    }
//}



struct NewWidget_Previews: PreviewProvider {
    
    static var previews: some View {
       NewWidget()
    }
}

//
//  NewWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/1/1.
//

import Foundation
import SwiftUI

var imageViewTest = CanvasWidget(width: 250, height:  250, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")


var videoViewTest = CanvasWidget(width: 250, height: 250, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Video Widget", widgetDescription: "Nice vid")



struct NewWidget: View {
    
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
   
   
    
    
    @Environment(\.dismiss) var dismissScreen
    
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    
    
//
//    private let widgetsExample: [String] = ["widget1", "widget2", "widget3", "widget4", "widget5", "widget6", "widget7", "widget8", "widget9", "widget10"]
//    
    
    
    
    private let widgets: [CanvasWidget] = [imageViewTest, videoViewTest, imageViewTest, imageViewTest, imageViewTest]
    
    
    
    
    var body: some View {
        
        ZStack {

            
            NavigationView{
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        ForEach(0..<widgets.count, id: \.self) {index in
                            
                            VStack{
                                
                                
                                //widget
                                getMediaView(widget: widgets[index])
                                    .aspectRatio(1, contentMode: .fit)
                                    .shadow(radius: 20, y: 10)
                                    .cornerRadius(30)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                
                                
                                //spacer
                                Spacer()
                                    .frame(height:10)
                                
                                //name
                                if let name = widgets[index].widgetName {
                                    Text(name)
                                        .foregroundStyle(.primary)
                                        .font(.headline)
                                        .fontWeight(.regular)
                                }
                                
                                //description
                                if let description = widgets[index].widgetDescription {
                                    Text(description)
                                        .foregroundStyle(.secondary)
                                        .font(.headline)
                                        .fontWeight(.regular)
                                    
                                }
                                
                            }
                            .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.8)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                                    .blur(radius: phase.isIdentity ? 0 : 3)
                                
                            }
                            
                        }
                    }
                    .scrollTargetLayout()
                    
                }
                
                .contentMargins(50, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding()
               
                .navigationTitle("Add a Widget 🙈")
                
                
                
            }
      
            
            
            
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

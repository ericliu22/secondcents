//
//  NewWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/1/1.
//

import Foundation
import SwiftUI
import PhotosUI




var imageViewTest = CanvasWidget(width: 250, height:  250, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")


var videoViewTest = CanvasWidget(width: 250, height: 250, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Video Widget", widgetDescription: "Nice vid")



struct NewWidgetView: View {
    

    @StateObject private var viewModel = NewWidgetViewModel()
    
    @State private var currentIndex: Int = 0
    
    
    
    @Environment(\.dismiss) var dismissScreen
    
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    private let widgets: [CanvasWidget] = [imageViewTest, videoViewTest, imageViewTest, imageViewTest, imageViewTest]
    
    @Binding var showNewWidgetView: Bool
    @Binding var showCustomizeWidgetView: Bool
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    @State var spaceId: String
    
    
    var body: some View {
        
        ZStack {
            NavigationView{
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        ForEach(0..<widgets.count, id: \.self) {index in
                            
                            VStack{
                                
                                switch widgets[index].media {
                                case .image:
                                    //widget
                                    
                                    
                                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
                                        
                                        
                                        getMediaView(widget: widgets[index])
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(radius: 20, y: 10)
                                            .cornerRadius(30)
                                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                        
                                        
                                    }
                                    
                                    
                                default:
                                    getMediaView(widget: widgets[index])
                                        .aspectRatio(1, contentMode: .fit)
                                        .shadow(radius: 20, y: 10)
                                        .cornerRadius(30)
                                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                }
                                
                                
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
        .task{
            
            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            
            print(viewModel.space?.name)
            
        
            
        }
        
        .onChange(of: selectedPhoto, perform: { newValue in
            if let newValue {
                                viewModel.saveTempImage(item: newValue)
            }
        })
        
        
        
    }
}


struct NewWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewWidgetView(showNewWidgetView: .constant(true), showCustomizeWidgetView: .constant(false), spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    }
}

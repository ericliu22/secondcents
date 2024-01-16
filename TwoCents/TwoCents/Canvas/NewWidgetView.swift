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
    
  
    
   
    
    @Environment(\.dismiss) var dismissScreen
    

    
    
    @Binding var showNewWidgetView: Bool
    @Binding var showCustomizeWidgetView: Bool
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    @State var spaceId: String
    
    
    var body: some View {
        
        ZStack {
            NavigationView{
                VStack{
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack {
                            ForEach(0..<viewModel.widgets.count, id: \.self) {index in
                                
                                VStack{
                                    //name
                                    if let name = viewModel.widgets[index].widgetName {
                                        Text(name)
                                            .foregroundStyle(.primary)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity)
                                            .visualEffect { content, geometryProxy in
                                                content
                                                    .offset(x: scrollOffset(geometryProxy))
                                            }
                                        
                                    }
                                    
                                    
                                    //description
                                    if let description = viewModel.widgets[index].widgetDescription {
                                        Text(description)
                                            .foregroundStyle(.secondary)
                                            .font(.headline)
                                            .fontWeight(.regular)
                                            .frame(maxWidth: .infinity)
                                            .visualEffect { content, geometryProxy in
                                                content
                                                    .offset(x: scrollOffset(geometryProxy))
                                            }
                                            .padding(.bottom, 100)
                                        
                                        
                                    
                                    
                                        
                                        
                                        switch viewModel.widgets[index].media {
                                    case .image:
                                        //widget
                                        
                                        
                                        PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
                                            
                                            
                                            getMediaView(widget: viewModel.widgets[index])
                                                .aspectRatio(1, contentMode: .fit)
                                                .shadow(radius: 20, y: 10)
                                                .cornerRadius(30)
                                                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                                
                                        }
                                        
                                        
                                        
                                    default:
                                            getMediaView(widget: viewModel.widgets[index])
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(radius: 20, y: 10)
                                            .cornerRadius(30)
                                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                    }
                                    
                                    
                                        Spacer()
                                
                                   
                                        
                                        
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
                    .frame(maxHeight: .infinity, alignment: .top)
//                    .background(.red)
                    
                    .contentMargins(50, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding()
                   
                    
                    
                    Button {
                        
                        viewModel.saveImageWidget()
                        dismissScreen()
                    } label: {
                        Text("Add Widget")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .padding(.horizontal)

                    
                    
                }
                
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
            
            print(viewModel.space?.name ?? "Space not available")
            
        
            
        }
        
        .onChange(of: selectedPhoto, perform: { newValue in
            if let newValue {
                viewModel.saveTempImage(item: newValue)
                
                 
//                widgets[0] = CanvasWidget(width: 250, height:  250, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: viewModel.url)!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")
            }
        })
        
        
        
    }
}


func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
    let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
    
    //0.6 speed of main content
    return -minX * 0.5
}


struct NewWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewWidgetView(showNewWidgetView: .constant(true), showCustomizeWidgetView: .constant(false), spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F")
    }
}

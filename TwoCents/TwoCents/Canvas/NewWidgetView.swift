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
    @State var widgetId: String
    
    
    
    
    @StateObject private var viewModel = NewWidgetViewModel()
    
    
    
    
    
    @Environment(\.dismiss) var dismissScreen
    
    
    
    
    @Binding var showNewWidgetView: Bool
    
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedVideo: PhotosPickerItem? = nil
    //    @State private var imagePreview: UIImage?
    
    @State var spaceId: String
    
    @Binding var photoLinkedToProfile: Bool
    
    
    var body: some View {
        
        ZStack {
            NavigationView{
                VStack{
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<viewModel.widgets.count, id: \.self) {index in
                                VStack{
                                    
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
                                                .padding(.bottom, 60)
                                        }
                                        //Widget Body
                                        switch viewModel.widgets[index].media {
                                            case .image:
                                                //image widget
                                                ZStack{
                                                    
                                                    //main widget/photopicker
                                                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
                                                        
                                                        getMediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                                                            .aspectRatio(1, contentMode: .fit)
                                                            .shadow(radius: 20, y: 10)
                                                            .cornerRadius(30)
                                                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                                        
                                                    }
                                                    //loading circle
                                                    if viewModel.loading {
                                                        ProgressView()
                                                            .progressViewStyle(
                                                                CircularProgressViewStyle(tint:
                                                                        .primary)
                                                            )
                                                            .frame(width: viewModel.widgets[index].width, height: viewModel.widgets[index].height)
                                                            .cornerRadius(30)
                                                        
                                                    }
                                                }
                                            case .video:
                                                ZStack{
                                                    
                                                    //main widget/photopicker
                                                    PhotosPicker(selection: $selectedPhoto, matching: .videos, photoLibrary: .shared()){
                                                        
                                                        getMediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                                                            .aspectRatio(1, contentMode: .fit)
                                                            .shadow(radius: 20, y: 10)
                                                            .cornerRadius(30)
                                                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                                        
                                                    }
                                                    //loading circle
                                                    if viewModel.loading {
                                                        ProgressView()
                                                            .progressViewStyle(
                                                                CircularProgressViewStyle(tint:
                                                                        .primary)
                                                            )
                                                            .frame(width: viewModel.widgets[index].width, height: viewModel.widgets[index].height)
                                                            .cornerRadius(30)
                                                        
                                                    }
                                                }
                                            default:
                                                ZStack{
                                                    
                                                    //default widgets
                                                    getMediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                                                        .aspectRatio(1, contentMode: .fit)
                                                        .shadow(radius: 20, y: 10)
                                                        .cornerRadius(30)
                                                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                                }
                                        }
                                        
                                    }
                                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.8)
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                                            .blur(radius: phase.isIdentity ? 0 : 3)
                                        
                                        
                                        
                                    }
                                    
                                    
                                    Spacer()
                                        .frame(height:30)
                                    
                                    
                                    //button
                                    switch index {
                                    case 0:
                                        Button {
                                            //@TODO: look into just making it index instead of hardcoding each index
                                            viewModel.saveWidget(index: index)
                                            
                                            if !viewModel.loading {
                                                photoLinkedToProfile = true
                                            }
                                            
                                            dismissScreen()
                                        } label: {
                                            Text("Add Widget")
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .buttonBorderShape(.capsule)
                                        .padding(.horizontal)
                                        .disabled(viewModel.loading || (selectedPhoto == nil))
                                    case 1:
                                        Button {
                                            viewModel.saveWidget(index: index)
                                            
                                            if !viewModel.loading {
                                                photoLinkedToProfile = true
                                            }
                                            
                                            dismissScreen()
                                        } label: {
                                            Text("Add Widget")
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .buttonBorderShape(.capsule)
                                        .padding(.horizontal)
                                        .disabled(viewModel.loading || (selectedVideo == nil))
                                    default:
                                        Button {
                                            
                                            dismissScreen()
                                        } label: {
                                            Text("Add Widget")
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .buttonBorderShape(.capsule)
                                        .padding(.horizontal)
                                        .disabled(true)
                                        
                                    }
                                }
                            }
                        }
                        .scrollTargetLayout()
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .contentMargins(50, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding()
                    
                }
                .navigationTitle("Add a Widget 🙈")
            }
            
            //cross to dismiss screen
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
                
                viewModel.loading = true
                viewModel.saveTempImage(item: newValue, widgetId: widgetId)
                
            }
        })
//        .presentationBackground(.thickMaterial)
    }
}


//to make scroll transition effect cool
func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
    let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
    
    
    return -minX * 0.6
}


struct NewWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewWidgetView(widgetId: UUID().uuidString, showNewWidgetView: .constant(true),  spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F", photoLinkedToProfile: .constant(false))
    }
}

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

var pollViewTest = CanvasWidget(width: 250, height: 250, borderColor: .red, userId: "jisookim", media: .poll, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Poll Widget", widgetDescription: "Scholars, gather your consensus")
var mapViewTest = CanvasWidget(width: 250, height: 250, borderColor: .red, userId: "jisookim", media: .map, widgetName: "Map Widget", widgetDescription: "Drop the addy")



struct NewWidgetView: View {
    
    @State var widgetId: String
    
    
    @StateObject private var viewModel = NewWidgetViewModel()
    
    
    @Environment(\.dismiss) var dismissScreen
    
    
    
    
//    @Binding var showNewWidgetView: Bool
    
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedVideo: PhotosPickerItem? = nil
    //    @State private var imagePreview: UIImage?
    
    @State var spaceId: String
    
    @State var closeNewWidgetview: Bool = false
    
    @Binding var photoLinkedToProfile: Bool
    
    func newVideoView(index: Int) -> some View {
        ZStack{
            
            //main widget/photopicker
            PhotosPicker(selection: $selectedVideo, matching: .videos, photoLibrary: .shared()){
                
                MediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                    .aspectRatio(1, contentMode: .fit)
//                    .shadow(radius: 20, y: 10)
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

    }
    
    func newImageView(index: Int) -> some View {
        
        ZStack{
            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
                
                MediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                    .aspectRatio(1, contentMode: .fit)
//                    .shadow(radius: 20, y: 10)
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
    }
    
    func newPollView(index: Int) -> some View {
        ZStack{
            
            //main widget/photopicker
            //let options: [Option] = [Option(name: "Option 1"), Option(name: "Option 2")]
            NewPoll(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
                .aspectRatio(1, contentMode: .fit)

//                .shadow(radius: 20, y: 10)
                .cornerRadius(30)
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                
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
        .onChange(of: closeNewWidgetview) { oldValue, newValue in
            if newValue {
                dismissScreen()
            }
        }
    }
    func newMapView(index: Int) -> some View {
        
        ZStack{
          
//            
//            getMediaView(widget: viewModel.widgets[index], spaceId: spaceId)
//                .aspectRatio(1, contentMode: .fit)
//            //                    .shadow(radius: 20, y: 10)
//                .cornerRadius(30)
//                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
//            
            
            NewMapView(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
                .cornerRadius(30)
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
    }
    
    
    
    func imageButton(index: Int) {
        viewModel.saveWidget(index: index)
        
        if !viewModel.loading {
            photoLinkedToProfile = true
        }
        dismissScreen()
    }
    
    func videoButton(index: Int) {
        viewModel.saveWidget(index: index)
        if !viewModel.loading {
            photoLinkedToProfile = true
        }
        dismissScreen()
    }
    
    
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
                                                .frame(maxWidth: .infinity, alignment: .center)
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
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .visualEffect { content, geometryProxy in
                                                    content
                                                        .offset(x: scrollOffset(geometryProxy))
                                                }
                                                .padding(.bottom, 60)
                                        }
                                        //Widget Body
                                        switch viewModel.widgets[index].media {
                                            case .image:
                                                newImageView(index: index)
                                            case .video:
                                                newVideoView(index: index)
                                            case .poll:
                                                newPollView(index: index)
//                                                .tint(.red)
                                            case .map:
                                                newMapView(index: index)
                                            
                                        default:
                                                ZStack{
                                                    
                                                    //default widgets
                                                    MediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                                                        .aspectRatio(1, contentMode: .fit)
//                                                        .shadow(radius: 20, y: 10)
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
                                            imageButton(index: index)
                                        }
                                        label: {
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
                                            videoButton(index: index)
                                        }
                                        label: {
                                            Text("Add Widget")
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .buttonBorderShape(.capsule)
                                        .padding(.horizontal)
                                        .disabled(viewModel.loading || (selectedVideo == nil))
                                    case 2:
                                            Button {
                                                viewModel.saveWidget(index: index)
                                                
//                                                if !viewModel.loading {
//                                                    photoLinkedToProfile = true
//                                                }
                                                
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        .onChange(of: selectedVideo, perform: { newValue in
            print("Selected Video")
            if let newValue {
                viewModel.loading = true
                viewModel.saveTempVideo(item: newValue, widgetId: widgetId)
                
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
        NewWidgetView(widgetId: UUID().uuidString, spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F", photoLinkedToProfile: .constant(false))
    }
}

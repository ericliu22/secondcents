//
//  NewWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/1/1.
//

import Foundation
import SwiftUI
import PhotosUI




var imageViewTest = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")





var videoViewTest = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Video Widget", widgetDescription: "Nice vid")

var pollViewTest = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .poll, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Poll Widget", widgetDescription: "Scholars, gather your consensus")
var mapViewTest = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .map, widgetName: "Map Widget", widgetDescription: "Drop the addy")



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
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    
    
    func newVideoView(index: Int) -> some View {
        ZStack{
            
            //main widget/photopicker
            PhotosPicker(selection: $selectedVideo, matching: .videos, photoLibrary: .shared()){
                
                MediaView(widget: viewModel.widgets[index], spaceId: spaceId)
//                    .aspectRatio(1, contentMode: .fit)
//                    .shadow(radius: 20, y: 10)
                    .cornerRadius(20)
//                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                
            }
            //loading circle
            if viewModel.loading {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint:
                                .primary)
                    )
//                    .frame(width: viewModel.widgets[index].width, height: viewModel.widgets[index].height)
                    .cornerRadius(20)
                
            }
        }
        
        

    }
    

    
   
    
    func newImageView(index: Int) -> some View {
            Group {
                if viewModel.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .aspectRatio(1, contentMode: .fit)
                        .background(.thickMaterial)
                        .cornerRadius(20)
                } else {
                    PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images, .videos]), photoLibrary: .shared()) {
                        ZStack {
                            if let image = viewModel.latestImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else if let videoThumbnail = viewModel.latestVideoThumbnail {
                                Image(uiImage: videoThumbnail)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.thinMaterial)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
        }
    
//    
//    func loadLatestPhoto() {
//            PHPhotoLibrary.requestAuthorization { status in
//                if status == .authorized {
//                    let fetchOptions = PHFetchOptions()
//                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//                    fetchOptions.fetchLimit = 1
//                    
//                    let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//                    if let asset = fetchResult.firstObject {
//                        let imageManager = PHImageManager.default()
//                        let options = PHImageRequestOptions()
//                        options.isSynchronous = true
//                        options.deliveryMode = .highQualityFormat
//                        
//                        let targetSize = CGSize(width: 400, height:400)
//                        
//                        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
//                            if let image = image {
//                                // Crop the image to a square
//                                let croppedImage = self.cropToSquare(image: image)
//                                
//                                DispatchQueue.main.async {
//                                    self.latestImage = croppedImage
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//    }
    
    func cropToSquare(image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        let imageSize = CGSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
        
        let cropSize = min(imageSize.width, imageSize.height)
        let x = (imageSize.width - cropSize) / 2.0
        let y = (imageSize.height - cropSize) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
    
    func newPollView(index: Int) -> some View {
        ZStack{
            
            //main widget/photopicker
            //let options: [Option] = [Option(name: "Option 1"), Option(name: "Option 2")]
            NewPoll(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
//                .aspectRatio(1, contentMode: .fit)

//                .shadow(radius: 20, y: 10)
                .cornerRadius(20)
//                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                
            //loading circle
            if viewModel.loading {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint:
                                .primary)
                    )
//                    .frame(width: viewModel.widgets[index].width, height: viewModel.widgets[index].height)
                    .cornerRadius(20)
                
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
                .cornerRadius(20)
            //loading circle
            if viewModel.loading {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint:
                                .primary)
                    )
//                    .frame(width: viewModel.widgets[index].width, height: viewModel.widgets[index].height)
                    .cornerRadius(20)
                
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
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: nil) {
                            
                            
                            ForEach(0..<viewModel.widgets.count, id: \.self) {index in
//                                VStack{
                               
//                                        //name
//                                        if let name = viewModel.widgets[index].widgetName {
//                                            Text(name)
//                                                .foregroundStyle(.primary)
//                                                .font(.title)
//                                                .fontWeight(.bold)
//                                                .frame(maxWidth: .infinity, alignment: .center)
////                                                .visualEffect { content, geometryProxy in
////                                                    content
////                                                        .offset(x: scrollOffset(geometryProxy))
////                                                }
//                                        }
//                                        
//                                        //description
//                                        if let description = viewModel.widgets[index].widgetDescription {
//                                            Text(description)
//                                                .foregroundStyle(.secondary)
//                                                .font(.headline)
//                                                .fontWeight(.regular)
//                                                .frame(maxWidth: .infinity, alignment: .center)
////                                                .visualEffect { content, geometryProxy in
////                                                    content
////                                                        .offset(x: scrollOffset(geometryProxy))
////                                                }
//                                                .padding(.bottom, 60)
//                                        }
//                                    
                                    
                                //Widget Body
                                switch viewModel.widgets[index].media {
                                    case .image:
                                        newImageView(index: index)
                                        .aspectRatio(1, contentMode: .fit)
                                        
                                    case .video:
                                        newVideoView(index: index)
                                        .aspectRatio(1, contentMode: .fit)
                                       
                                    case .poll:
                                        newPollView(index: index)
                                        .aspectRatio(1, contentMode: .fit)
                                       
//
                                    case .map:
                                        newMapView(index: index)
                                        .aspectRatio(1, contentMode: .fit)
                                        
                                    
                                default:
                                        ZStack{
                                            
                                            //default widgets
                                            MediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                                                .aspectRatio(1, contentMode: .fit)
//                                                        .shadow(radius: 20, y: 10)
                                                .cornerRadius(30)
//                                                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                        }
                                }
                                
                                       
                                        
                                    
                                    
//                                    
//                                    Spacer()
//                                        .frame(height:30)
//                                    
//                                    
//                                    //button
//                                    switch index {
//                                    case 0:
//                                        Button {
//                                            imageButton(index: index)
//                                        }
//                                        label: {
//                                            Text("Add Widget")
//                                                .padding(.vertical, 10)
//                                                .frame(maxWidth: .infinity)
//                                        }
//                                        .buttonStyle(.bordered)
//                                        .buttonBorderShape(.capsule)
//                                        .padding(.horizontal)
//                                        .disabled(viewModel.loading || (selectedPhoto == nil))
//                                    case 1:
//                                        Button {
//                                            videoButton(index: index)
//                                        }
//                                        label: {
//                                            Text("Add Widget")
//                                                .padding(.vertical, 10)
//                                                .frame(maxWidth: .infinity)
//                                        }
//                                        .buttonStyle(.bordered)
//                                        .buttonBorderShape(.capsule)
//                                        .padding(.horizontal)
//                                        .disabled(viewModel.loading || (selectedVideo == nil))
//                                    case 2:
//                                            Button {
//                                                viewModel.saveWidget(index: index)
//                                                
////                                                if !viewModel.loading {
////                                                    photoLinkedToProfile = true
////                                                }
//                                                
//                                                dismissScreen()
//                                            } label: {
//                                                Text("Add Widget")
//                                                    .padding(.vertical, 10)
//                                                    .frame(maxWidth: .infinity)
//                                            }
//                                            .buttonStyle(.bordered)
//                                            .buttonBorderShape(.capsule)
//                                            .padding(.horizontal)
//                                            .disabled(viewModel.loading || (selectedVideo == nil))
//                                        
//                                        
//                                    default:
//                                        Button {
//                                            
//                                            dismissScreen()
//                                        } label: {
//                                            Text("Add Widget")
//                                                .padding(.vertical, 10)
//                                                .frame(maxWidth: .infinity)
//                                        }
//                                        .buttonStyle(.bordered)
//                                        .buttonBorderShape(.capsule)
//                                        .padding(.horizontal)
//                                        .disabled(true)
//                                        
//                                    }
//                                
//
                                }
                                
                               
                             
//                            }
                        }
//                        .scrollTargetLayout()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                    .contentMargins(50, for: .scrollContent)
//                    .scrollTargetBehavior(.viewAligned)
//                    .safeAreaPadding()
                    
                }
                .padding(.horizontal)
                .navigationTitle("Add a Widget 🙈")
                .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
                   viewModel.loadLatestMedia()
               }
        .onChange(of: selectedPhoto) { newValue in
            if let newValue {
                viewModel.loading = true
                print("Supported Content Types: \(newValue.supportedContentTypes.map { $0.identifier })")
                
                let imageUTTypes: [UTType] = [.jpeg, .png]
        
                
                if newValue.supportedContentTypes.contains(where: { imageUTTypes.contains($0) }) {
                    print("Saving image")
                    viewModel.saveTempImage(item: newValue, widgetId: widgetId) { success in
                        if success {
                            imageButton(index: 0)
                        } else {
                            print("Failed to save image.")
                        }
                        viewModel.loading = false
                    }
                } else {
                    print("Saving video")
                    viewModel.saveTempVideo(item: newValue, widgetId: widgetId) { success in
                        if success {
                            videoButton(index: 1)
                        } else {
                            print("Failed to save video.")
                        }
                        viewModel.loading = false
                    }
                }
            }
        }




//        .onChange(of: selectedVideo, perform: { newValue in
//            print("Selected Video")
//            if let newValue {
//                viewModel.loading = true
//                viewModel.saveTempVideo(item: newValue, widgetId: widgetId)
//                
//            }
//        })
//        .presentationBackground(.thickMaterial)
    }
}


//to make scroll transition effect cool
//func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
//    let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
//    
//    
//    return -minX * 0.6
//}


struct NewWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewWidgetView(widgetId: UUID().uuidString, spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F", photoLinkedToProfile: .constant(false))
    }
}

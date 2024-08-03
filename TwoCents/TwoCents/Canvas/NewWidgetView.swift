//
//  NewWidget.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/1/1.
//

import Foundation
import SwiftUI
import PhotosUI




var imageViewTest = CanvasWidget(width: .infinity, height:  .infinity, x: 0, y: 0, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: "https://m.media-amazon.com/images/M/MV5BN2Q0OWJmNWYtYzBiNy00ODAyLWI2NGQtZGFhM2VjOWM5NDNkXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_.jpg")!, widgetName: "Library", widgetDescription: "Expose someone")

var videoViewTest = CanvasWidget(width: .infinity, height:  .infinity, x: 0, y: 0, borderColor: .red, userId: "jisookim", media: .video, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Video", widgetDescription: "Nice vid")

var pollViewTest = CanvasWidget(width: .infinity, height:  .infinity, x: 0, y: 0, borderColor: .red, userId: "jisookim", media: .poll, mediaURL: URL(string: "https://www.pexels.com/video/10167684/download/")!, widgetName: "Poll", widgetDescription: "Gather consensus")
var mapViewTest = CanvasWidget(width: .infinity, height:  .infinity, x: 0, y: 0, borderColor: .red, userId: "jisookim", media: .map, widgetName: "Map", widgetDescription: "Drop the addy")

var textViewTest = CanvasWidget(width: .infinity, height:  .infinity, x: 0, y:0, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch")

var todoViewTest = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .todo, widgetName: "List", widgetDescription: "Conquer the world", textString: "")

var linkViewTest = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .link, widgetName: "Link", widgetDescription: "Share a link", textString: "")



struct NewWidgetView: View {
    
    @State var widgetId: String
    @State private var userColor: Color = .gray
    
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
    
    
    func newImageView(index: Int) -> some View {
        Group {
            if viewModel.loading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(.thinMaterial)
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
    
    
    func newPollView(index: Int) -> some View {
        ZStack{
            
           
            NewPoll(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
          
                .cornerRadius(20)
          
        }
       
    }
    
    
    
    func newTodoView(index: Int) -> some View {
        ZStack{
            
           
            NewTodoView(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
          
                .cornerRadius(20)
          
        }
       
    }
    
    
    
    func newMapView(index: Int) -> some View {
        
        ZStack{
            
            NewMapView(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
                .cornerRadius(20)
          
        }
    }
    
    func newLinkView(index: Int) -> some View {
        NewLinkView(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
    }
    
    
    @State private var showingView: Bool = false
    
    
    func newTextView(index: Int) -> some View {
        
        
        
        ZStack{
           
            
            
            Text("Fruits can't even see so tell me how my Apple Watch")
                .multilineTextAlignment(.leading)
                .font(.custom("LuckiestGuy-Regular", size: 24, relativeTo: .headline))
                .padding(5)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThickMaterial)
                .background(userColor)
                .foregroundColor(userColor)
                .cornerRadius(20)
          
            
                .onTapGesture {
                    showingView.toggle()
                    print("tapped")
                }
            
                .fullScreenCover(isPresented: $showingView, content: {
                    
                    NewTextWidgetView(spaceId: spaceId, closeNewWidgetview: $closeNewWidgetview)
                     
                })
                
             
            
            
        }
        
    }
    
    
    
    
    
    func imageSave(index: Int) {
        viewModel.saveWidget(index: index)
        
        if !viewModel.loading {
            photoLinkedToProfile = true
        }
        dismissScreen()
    }
    
    func videoSave(index: Int) {
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
                        Spacer()
                            .frame(height: 10)
                        LazyVGrid(columns: columns, spacing: nil) {
                            
                            
                            ForEach(0..<viewModel.widgets.count, id: \.self) {index in
                                VStack(spacing: 0) {
                                    
                                    //Widget Body
                                    switch viewModel.widgets[index].media {
                                    case .image:
                                        newImageView(index: index)
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 4)
                                                                    
                                        
                                    case .poll:
                                        newPollView(index: index)
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 4)
                                                                    
                                        //
                                    case .map:
                                        newMapView(index: index)
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 4)
                                    case .text:
                                        newTextView(index: index)
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 4)
                                                                    
                                    case .todo:
                                        newTodoView(index: index)
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 4)
                                    case .link:
                                        newLinkView(index: index)
                                            .aspectRatio(1, contentMode: .fit)
                                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 8, y: 4)

                                    default:
                                        ZStack{
                                            EmptyView()
                                            //default widgets
//                                            MediaView(widget: viewModel.widgets[index], spaceId: spaceId)
                                                .aspectRatio(1, contentMode: .fit)
                                            //                                                        .shadow(radius: 20, y: 10)
                                                .cornerRadius(30)
                                            //                                                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                        }
                                    }
                                       
                                        Spacer()
                                        .frame(height:6)
                                    
                                    //name
                                    if let name = viewModel.widgets[index].widgetName, let description = viewModel.widgets[index].widgetDescription {
                                        
                                        Text(name)
                                            .foregroundStyle(.primary)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                          
                                        Text(description)
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                            .fontWeight(.regular)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    
                                   
                                    Spacer()
                                    .frame(height:10)
                                }
                               
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                       
                        
                    }
                
                    .navigationTitle("Add a Widget 🙈")
//                    .navigationBarTitleDisplayMode(.inline)
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
            .onChange(of: closeNewWidgetview) { oldValue, newValue in
                if newValue {
                    dismissScreen()
                }
            }
            .task{
                try? await viewModel.loadCurrentSpace(spaceId: spaceId)
                print(viewModel.space?.name ?? "Space not available")
                
                
                
                try? await viewModel.loadCurrentUser()
                
                withAnimation {
                    userColor = Color.fromString(name: viewModel.user?.userColor ?? "")
                }
               
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
                                imageSave(index: 0)
                            } else {
                                print("Failed to save image.")
                            }
                            viewModel.loading = false
                        }
                    } else {
                        print("Saving video")
                        viewModel.saveTempVideo(item: newValue, widgetId: widgetId) { success in
                            if success {
                                videoSave(index: 1)
                            } else {
                                print("Failed to save video.")
                            }
                            viewModel.loading = false
                        }
                    }
                }
            }
            
            
            
            
        }
    }
    
    
    
    struct NewWidgetView_Previews: PreviewProvider {
        
        static var previews: some View {
            NewWidgetView(widgetId: UUID().uuidString, spaceId:"F531C015-E840-4B1B-BB3E-B9E7A3DFB80F", photoLinkedToProfile: .constant(false))
        }
    }

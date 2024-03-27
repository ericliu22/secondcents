//
//  CreateProfileViewModel.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import Foundation
import SwiftUI
import PhotosUI



@MainActor
final class NewWidgetViewModel: ObservableObject{
    
    
    
    
    
    
    @Published private(set) var space:  DBSpace? = nil
    func loadCurrentSpace(spaceId: String) async throws {
        
        self.space = try await SpaceManager.shared.getSpace(spaceId: spaceId)
        
    }
    
    
 
    @Published var loading: Bool = false
//    @Published var widgetId = UUID().uuidString
    
    
    private var path = ""
    private var url = ""
    
    
    @Published var widgets: [CanvasWidget] = [imageViewTest, videoViewTest]
    
    
    
    
    
    
    func saveTempImage(item: PhotosPickerItem, widgetId: String) {
      
    
        guard let space else { return }
        
        
        Task {
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            if let image = UIImage(data: data), let imageData = resizeImage(image: image, targetSize: CGSize(width: 250, height: 250))?.jpegData(compressionQuality: 1)  {
                
                
             
                
                let (path, name) = try await StorageManager.shared.saveTempWidgetPic(data: imageData, spaceId: space.spaceId, widgetId: widgetId)
                print ("Saved Image")
//                print (widgetId)
                print (path)
//                print (name)
                let url = try await StorageManager.shared.getURLForImage(path: path)
//                print(url)
                
                self.path = path
                self.url = url.absoluteString
    
                widgets[0] = CanvasWidget(width: 250, height:  250, borderColor: .black, userId: "jennierubyjane", media: .image, mediaURL: URL(string: self.url)!, widgetName: "Photo Widget", widgetDescription: "Add a photo to spice the convo")
                
                
                loading = false
             
                
                        
                  
                
               
            }
            
            
        }
        
    }
    
    func saveImageWidget(widgetId: String) {
      
    
        guard let space, !path.isEmpty, !url.isEmpty else { return }

        Task {
            
               
            try await SpaceManager.shared.setImageWidgetPic(spaceId: space.spaceId, widgetId: widgetId, url: self.url, path: self.path)
            try? await loadCurrentSpace(spaceId: space.spaceId)
           
            
        }
        
    }
    
    
    
    func saveWidget(index: Int) {
        //Need to copy to variable before uploading (something about actor-isolate whatever)
        let uploadWidget: CanvasWidget = widgets[index]
        Task {
            //space call should never fail so we manly !
            await SpaceManager.shared.uploadWidget(spaceId: space!.spaceId, widget: uploadWidget)
        }
    }
    
    
    
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio < heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            print( "width")
            print( size.width * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            
            print( "width")
            print( size.width * widthRatio)
        }
        
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

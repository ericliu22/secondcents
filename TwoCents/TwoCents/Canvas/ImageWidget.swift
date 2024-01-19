//
//  ImageWidget.swift
//  scrollable_canvas
//
//  Created by Eric Liu on 2023/8/24.
//

import Foundation
import SwiftUI

func imageWidget(widget: CanvasWidget) -> AnyView {
    @State var isPresented: Bool = false
    print(isPresented)
    assert(widget.media == .image)
    

    
    return AnyView(
        
        AsyncImage(url: widget.mediaURL) {image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: widget.width, height: widget.height)
                .clipShape(
                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
                )
                .onTapGesture {
                    print(isPresented)
                    isPresented.toggle();
                    print(isPresented)
                }
        } placeholder: {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint:
                            .primary)
                )
           
                .frame(width: widget.width, height: widget.height)
                .background(.thickMaterial)
        }//AsyncImage
          
       
    )//AnyView
    
//    
//    func updateMediaURL(url: String){
//       assert(widget.mediaURL == URL(string: url)!)
//       
//   }
//    
    
    
}
//testing struct with imageWidget2
//struct testNormal: View{
//    assert(widget.media == .image)
//    var body: some View{
//        AsyncImage(url: widget.mediaURL) {image in
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: widget.width, height: widget.height)
//                .clipShape(
//                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
//                )
//
//        } placeholder: {
//            
//        }//AsyncImage
//    }
//}



/*
func uploadTOFireBaseVideo(url: URL,
                                  success : @escaping (String) -> Void,
                                  failure : @escaping (Error) -> Void) {

    let name = "\(Int(Date().timeIntervalSince1970)).mp4"
    let path = NSTemporaryDirectory() + name

    let dispatchgroup = DispatchGroup()

    dispatchgroup.enter()

    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let outputurl = documentsURL.appendingPathComponent(name)
    var ur = outputurl
    self.convertVideo(toMPEG4FormatForVideo: url as URL, outputURL: outputurl) { (session) in

        ur = session.outputURL!
        dispatchgroup.leave()

    }
    dispatchgroup.wait()

    let data = NSData(contentsOf: ur as URL)

    do {

        try data?.write(to: URL(fileURLWithPath: path), options: .atomic)

    } catch {

        print(error)
    }

    let storageRef = Storage.storage().reference().child("Videos").child(name)
    if let uploadData = data as Data? {
        storageRef.putData(uploadData, metadata: nil
            , completion: { (metadata, error) in
                if let error = error {
                    failure(error)
                }else{
                    let strPic:String = (metadata?.downloadURL()?.absoluteString)!
                    success(strPic)
                }
        })
    }
}

func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
    try! FileManager.default.removeItem(at: outputURL as URL)
    let asset = AVURLAsset(url: inputURL as URL, options: nil)

    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously(completionHandler: {
        handler(exportSession)
    })
}

*/

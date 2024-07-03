//
//  ChatBubbleView.swift
//  TwoCents
//
//  Created by jonathan on 7/2/24.
//

import SwiftUI

struct ChatBubbleView: View {
    
    let message: Message
    
    let sentByMe: Bool
    let isFirstMsg: Bool
    
    let name: String

    
    @StateObject private var viewModel = ChattingViewModel()
    @State private var userColor: Color = .gray
//    @State var spaceId: String
    
    @State private var loaded: Bool = false
    
    
    
    
    
    var body: some View {
        VStack(alignment: sentByMe ? .trailing : .leading, spacing: 3){
            
            
            if isFirstMsg  {
                
             
                Text(name)
                    .foregroundStyle(userColor)
                    .font(.caption)
//                    .padding(.leading, 12)
                    .padding(sentByMe ? .trailing : .leading, 6)
                    .padding(.top, 3)

                    
            }
            
//            if message.text != "" &&  message.text != nil{
                
                
                //show text message if text is not nill
                Text(message.text! )
                    .font(.headline)
                    .fontWeight(.regular)
                //                .padding(10)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                //                .foregroundStyle(Color(UIColor.label))
                    .foregroundStyle(userColor)
                    .background(.ultraThickMaterial)
                    .background(userColor)
                
                //FOR ASYMETRIC ROUNDING...
                //                .clipShape(chatBubbleShape (sentByMe: sentByMe, isFirstMsg: isFirstMsg))
                //                .clipShape(RoundedRectangle(cornerRadius: 5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                    .frame(maxWidth: 300, alignment: sentByMe ?  .trailing : .leading)
                
//            } else {
//                
//                //show widget message if text is nil
//               
//              
//                if let widget =  viewModel.WidgetMessage {
//                    
//                    MediaView(widget: widget, spaceId: spaceId)
//                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: CORNER_RADIUS, style: .continuous))
//                        .cornerRadius(CORNER_RADIUS)
//                    
//                        .frame(maxWidth: .infinity, minHeight: TILE_SIZE, alignment: sentByMe ?  .trailing : .leading)
//                    
//                    
//                }
//
//               
//            }
            

        }
        .frame(maxWidth: .infinity, alignment: sentByMe ?  .trailing : .leading)
        
        
        
        
        
    }
}

//struct ChatBubbleView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatBubbleView(product: Message(id: 1, title: "Test", description: "test", price: 435, discountPercentage: 1345245, rating: 65231, stock: 1324, brand: "asdfasdf", category: "asdfafsd", thumbnail: "asdfafds", images: []))
//    }
//}

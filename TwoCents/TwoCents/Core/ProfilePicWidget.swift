//
//  ProfilePicWidget.swift
//  TwoCents
//
//  Created by jonathan on 10/4/23.
//

import SwiftUI

struct ProfilePicWidget: View {
    
    @State var urlString: String
    @State var tintColor: Color
    
    var body: some View {
        
        Group{
            //Circle or Profile Pic
            
            if let url = URL(string: urlString) {

                
                //If there is URL for profile pic, show
                //circle with stroke
                AsyncImage(url: url) {image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)
                    
                    
                    
                } placeholder: {
                    //else show loading after user uploads but sending/downloading from database
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                    //                            .scaleEffect(1, anchor: .center)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(tintColor)
                                .frame(width: 48, height: 48)
                        )
                }
                
            } else {
                
                //if user has not uploaded profile pic, show circle
                Circle()
                
                    .strokeBorder(tintColor, lineWidth:0)
                    .background(Circle().fill(tintColor))
                    .frame(width: 48, height: 48)
                
            }
            
            
            
            
        }
        
        
        
        
        
        
    }
}

#Preview {
    ProfilePicWidget(urlString: "", tintColor: .red)
}

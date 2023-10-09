//
//  CreateProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import SwiftUI
import PhotosUI

struct CustomizeProfileView: View {
    
    @State private var url: URL? = nil
    
    
    @StateObject private var viewModel = CustomizeProfileViewModel()
    
    @Binding var showCreateProfileView: Bool
    
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    @Binding var selectedColor: Color
    
    
    
    
    
    
    
    var body: some View {
        
        VStack {
            ZStack{
                
                
                //Circle or Profile Pic
                
                
                if let urlString = viewModel.user?.profileImageUrl, let url = URL(string: urlString) {
                    
                    
                    //If there is URL for profile pic, show
                    //circle with stroke
                    Circle()
//                        .strokeBorder(selectedColor, lineWidth:15)
                        .background(
                            //profile pic in middle
                            AsyncImage(url: url) {image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 176, height: 176)
                                
                            } placeholder: {
                                //else show loading after user uploads but sending/downloading from database
                                
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                    .scaleEffect(1.5, anchor: .center)
                                    .frame(width: 176, height: 176)
                                    .background(
                                        Circle()
                                            .fill(selectedColor)
                                            .frame(width: 176, height: 176)
                                    )
                            }
                            
                        )
                        .frame(width: 176, height: 176)
                    
                } else {
                    
                    //if user has not uploaded profile pic, show circle
                    Circle()
                    
//                        .strokeBorder(selectedColor, lineWidth:15)
                        .fill(selectedColor)
                        .frame(width: 176, height: 176)
                }
                
                
                
                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
                   
                    
                    ZStack{
                        
                        Circle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 64, height: 64)
                        
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 64, height: 64)
                        
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(UIColor.systemBackground))
                        
                        
                    }
                    
                    
                }
               
                .offset(x:60, y:60)
                
                
                
                
                
                
            }
            .padding(32)
            .background(.thinMaterial)
//            .background(in: <#T##S#>)
            .cornerRadius(20)
            
            
            Spacer()
                .frame(height:30)
            
            //Color Picker
            ColorPickerWidget(selectedColor: $selectedColor)
            
            
            Spacer()
                .frame(height:30)
           
            
            
            Button {
                
                showCreateProfileView.toggle()
                
            } label: {
                Text("Done")
                    .font(.headline)
              
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                
            }
            
            .buttonStyle(.bordered)
            .tint(selectedColor)
            .frame(height: 55)
            .cornerRadius(10)
            .padding(.horizontal)
            
            
            
            
            
            
        }
        .task{
            try? await viewModel.loadCurrentUser()
            
        }
        
        .onChange(of: selectedPhoto, perform: { newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
            }
        })
        .navigationTitle("Customize Profile 🎨")
    }
        
}


struct CustomizeProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CustomizeProfileView(showCreateProfileView: .constant(true), selectedColor: .constant(.red))
        }
    }
}

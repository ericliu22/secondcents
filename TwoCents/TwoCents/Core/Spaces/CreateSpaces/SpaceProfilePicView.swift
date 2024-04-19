//
//  SpaceProfilePicView.swift
//  TwoCents
//
//  Created by jonathan on 11/4/23.
//



import SwiftUI
import PhotosUI

struct SpaceProfilePicView: View {
    
    @State private var url: URL? = nil
    
    @State var spaceId: String
    @StateObject private var viewModel = SpaceProfilePicViewModel()
    
  
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    

    @Binding var isShowingCreateSpaces: Bool
    
    var body: some View {
        
        VStack {
            ZStack{
                
                
                //Circle or Profile Pic
                
                if let urlString = viewModel.space?.profileImageUrl, let url = URL(string: urlString) {
                    
                    
                    //If there is URL for profile pic, show
                    //circle with stroke
                 
                            //profile pic in middle
                            AsyncImage(url: url) {image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    
                                
                            } placeholder: {
                                //else show loading after user uploads but sending/downloading from database
                                
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                    .scaleEffect(1.5, anchor: .center)
                                    .background(
                                        Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 176, height: 176)
                                    )
                                    
                            }
                            
                        
                        .frame(width: 176, height: 176)
                    
                    .frame(width: 176, height: 176)
                    .clipShape(Circle())
                    
                } else {
                    
                    //if user has not uploaded profile pic, show circle
                    Circle()
                    
//                        .strokeBorder(selectedColor, lineWidth:15)
                        .fill(Color.accentColor)
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
//                            .fill(selectedColor)
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

            .cornerRadius(20)
            
            
            Button {
                
                isShowingCreateSpaces = false
               
//                    
//                CanvasPage(chatroom: db.collection("spaces").document(spaceId))
                
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
            }
            
            
            .buttonStyle(.bordered)
//            .tint(selectedColor)
            .frame(height: 55)
            .cornerRadius(10)
            .padding(.horizontal)
            
            
            
            
//            
//            
//            
//            
//            Button {
//                
//      
//                
//            } label: {
//                Text("Done")
//                    .font(.headline)
//              
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                
//            }
//            
//            .buttonStyle(.bordered)
////            .tint(selectedColor)
//            .frame(height: 55)
//            .cornerRadius(10)
//            .padding(.horizontal)
//            
//            
//            
            
            
            
        }
        .task{
            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            
        }
        
        .onChange(of: selectedPhoto, perform: { newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
            }
        })
        .navigationTitle("Customize Profile 🎨")
    }
        
}


struct SpaceProfilePicView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SpaceProfilePicView(spaceId: "56456522-E7FC-466E-83C1-85A0AE3DEC5B", isShowingCreateSpaces: .constant(false))
        }
    }
}



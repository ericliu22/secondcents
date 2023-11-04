
//
//  CreateProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import SwiftUI
import PhotosUI

struct CreateSpacesView: View {
    
    @State private var url: URL? = nil
    @State var spaceId: String
    
    @StateObject private var viewModel = CreateSpacesViewModel()
    
   
    
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    
    @State private var searchTerm = ""
    
    
    var filteredSearch: [DBUser]{
        guard !searchTerm.isEmpty else { return viewModel.allFriends}
        return viewModel.allFriends.filter{$0.name!.localizedCaseInsensitiveContains(searchTerm) || $0.username!.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    
    
    
    var body: some View {
        
        VStack {
//            ZStack{
//                
//                
//                //Circle or Profile Pic
//                
//                
//                if let urlString = viewModel.space?.profileImageUrl, let url = URL(string: urlString) {
//                    
//                    
//                    //If there is URL for profile pic, show
//                    //circle with stroke
//                    Circle()
////                        .strokeBorder(selectedColor, lineWidth:15)
//                        .background(
//                            //profile pic in middle
//                            AsyncImage(url: url) {image in
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//                                    .clipShape(Circle())
//                                    .frame(width: 176, height: 176)
//                                
//                            } placeholder: {
//                                //else show loading after user uploads but sending/downloading from database
//                                
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
//                                    .scaleEffect(1.5, anchor: .center)
//                                    .frame(width: 176, height: 176)
//                                    .background(
//                                        Circle()
//                                            .fill(Color.accentColor)
//                                            .frame(width: 176, height: 176)
//                                    )
//                            }
//                            
//                        )
//                        .frame(width: 176, height: 176)
//                    
//                } else {
//                    
//                    //if user has not uploaded profile pic, show circle
//                    Circle()
//                    
////                        .strokeBorder(selectedColor, lineWidth:15)
//                        .fill(Color.accentColor)
//                        .frame(width: 176, height: 176)
//                }
//                
//                
//                
//                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
//                   
//                    
//                    ZStack{
//                        
//                        Circle()
//                            .fill(Color(UIColor.systemBackground))
//                            .frame(width: 64, height: 64)
//                        
//                        Circle()
//                            .fill(.thinMaterial)
//                            .frame(width: 64, height: 64)
//                        
//                        Circle()
//                            .fill(Color.accentColor)
//                            .frame(width: 48, height: 48)
//                        
//                        Image(systemName: "plus")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundColor(Color(UIColor.systemBackground))
//                        
//                        
//                    }
//                    
//                    
//                }
//               
//                .offset(x:60, y:60)
//                
//                
//                
//                
//                
//                
//            }
//            .padding(32)
//            .background(.thinMaterial)
//
//            .cornerRadius(20)
//            
//            
    
            
            
            //Name Textfield
            TextField("Name", text: $viewModel.name)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
         
            
            //Friends
            
            VStack(alignment:.leading){
                
                Text("Friends 💛")
                    .font(.title3)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack{
                        
                        ForEach(filteredSearch) { userTile    in
                            let targetUserColor: Color = viewModel.getUserColor(userColor: userTile.userColor!)
                            
                            Group{
                                
                                
                                HStack{
                                    
                                    
                                    
                                    Group{
                                        //Circle or Profile Pic
                                        
                                        
                                        if let urlString = userTile.profileImageUrl,
                                           let url = URL(string: urlString) {
                                            
                                            
                                            
                                            //If there is URL for profile pic, show
                                            //circle with stroke
                                            AsyncImage(url: url) {image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                                    .frame(width: 16, height: 16)
                                                
                                                
                                                
                                            } placeholder: {
                                                //else show loading after user uploads but sending/downloading from database
                                                
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                                    .scaleEffect(0.5, anchor: .center)
                                                    .frame(width: 16, height: 16)
                                                    .background(
                                                        Circle()
                                                            .fill(targetUserColor)
                                                            .frame(width: 16, height: 16)
                                                    )
                                            }
                                            
                                        } else {
                                            
                                            //if user has not uploaded profile pic, show circle
                                            Circle()
                                            
                                                .strokeBorder(targetUserColor, lineWidth:0)
                                                .background(Circle().fill(targetUserColor))
                                                .frame(width: 16, height: 16)
                                            
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    
                                    Text(userTile.name!)
                                        .font(.headline)
                                    
                                }
                            }
                            .padding(.horizontal,5)
                            .padding(.vertical,2.5)
                            
                            .background(.thickMaterial, in: Capsule())
                            .background(targetUserColor, in: Capsule())
                            //                    .background(Capsule()
                            //                        .fill(.thickMaterial)
                            //                        .fill(targetUserColor)
                            //                        )
                            
                        }
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            Button {
                //signUp
                Task {
                    do {
                        try await viewModel.createSpace(spaceId: spaceId)
                  
                        return
                    } catch {
                    }
                }
               
                
                
               
                
            } label: {
                Text("Done")
                    .font(.headline)
              
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                
            }
            
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .frame(height: 55)
            .cornerRadius(10)
//            .padding(.horizontal)
            
            
            
            
            
            
        }
        .padding()
        .task{
            try? await viewModel.loadCurrentSpace(spaceId: spaceId)
            try? await viewModel.getAllFriends()
            
        }
        
//        .onChange(of: selectedPhoto, perform: { newValue in
//            if let newValue {
//           
//                viewModel.saveProfileImage(item: newValue, spaceId: spaceId)
//            }
//        })
        .navigationTitle("Create Space 💭")
    }
        
}


struct CreateSpacesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CreateSpacesView(spaceId: UUID().uuidString)
        }
    }
}

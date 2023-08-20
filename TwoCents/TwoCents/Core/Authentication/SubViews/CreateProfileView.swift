//
//  CreateProfileView.swift
//  TwoCents
//
//  Created by jonathan on 8/20/23.
//

import SwiftUI
import PhotosUI

struct CreateProfileView: View {
    
    @Binding var showSignInView: Bool
    @State private var url: URL? = nil
    
    
    @StateObject private var viewModel = CreateProfileEmailViewModel()
    
    
    
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    
    var body: some View {
        
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()){
                Text("Select a photo")
            }
            
            if let urlString = viewModel.user?.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) {image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 150)
                }
            }
            
            
            
            
            
        }
        .task{
            try? await viewModel.loadCurrentUser()
            
        }
        .onChange(of: selectedItem, perform: { newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
                
                
            }
            
            
        })
        .navigationTitle("Create Profile")
        
        
        
        
    }
    
    
}


struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CreateProfileView(showSignInView: .constant(false))
        }
    }
}

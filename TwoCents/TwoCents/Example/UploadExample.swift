//
//  UploadExample.swift
//  TwoCents
//
//  Created by jonathan on 8/15/23.
//

import SwiftUI

struct UploadExample: View {
    
    //NEED THIS LINE OF CODE TO CONNECT OT VIEWMODEL DOCUMENT
    //VIEWMODEL DOCUMENT IS WHERE ALL THE FUNCTIONS ARE
    @StateObject private var viewModel = UploadExampleViewModel()
    
    
    var body: some View {
        VStack {
            //LIST TO DISPLAY USER INFO... CAN IGNORE
            List{
                if let user = viewModel.user {
                    
                    //name
                    if let name = user.name {
                        Text("Name: \(name)")
                    }
                    
                    //User Id
                    Text("UserId: \(user.userId)")
                }
            }
            .task{
                try? await viewModel.loadCurrentUser()
            }
            .navigationTitle("Uploading To Firestore")
            
            
            
            //TEXTFIELD TO INPUT DATA TO BE UPLOADED
            TextField("Enter Fav BlackPink Member", text: $viewModel.inputVariable)
                .textFieldStyle(.roundedBorder)
            
            
            //BUTTON TO UPDATE USER
            Button {
                Task {
                    do {
                        //THIS IS THE ACTION THAT UPDATES USER INFO.
                        //SEE UPLOAD EXAMPLE VIEWMODEL
                        try viewModel.updateUserInfo()
                        return
                    } catch {
                        
                    }
                }
            } label: {
                Text("Update User")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct UploadExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UploadExample()
        }
    }
}

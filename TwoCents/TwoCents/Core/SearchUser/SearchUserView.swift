//
//  SearchUserView.swift
//  TwoCents
//
//  Created by jonathan on 9/7/23.
//

import SwiftUI

struct SearchUserView: View {
    
    @StateObject private var viewModel = SearchUserViewModel()
    var body: some View {
        //        VStack {
        //            ForEach(viewModel.images, id: \.id) { item in
        //                Text("URL: \(item.url)")
        //                Text("Quote: \(item.quote)")
        //            }
        //        }.onAppear { viewModel.fetchData() }
        
        VStack{
            ForEach(viewModel.friends) { friends in
                Text(friends.userId )
                
               
                
            }
            
            
                    
                    
            
        }
        .task {
            try? await viewModel.getAllFriends()
        }
        
        
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}

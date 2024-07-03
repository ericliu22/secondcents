//
//  FrontPageView.swift
//  TwoCents
//
//  Created by jonathan on 8/16/23.
//

import SwiftUI

struct FrontPageView: View {
    
   
    
//    @Binding var showSignInView: Bool
    @Binding var loadedColor: Color
//    @Binding var showCreateProfileView: Bool
    @Binding var activeSheet: sheetTypes?
    
    var body: some View {
        TabView{
//            UploadExample()
            
//            SpacesView(showSignInView: $showSignInView, loadedColor: $loadedColor, showCreateProfileView: $showCreateProfileView)
            SpacesView(activeSheet: $activeSheet, loadedColor: $loadedColor)
                .tabItem {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("Spaces")
                }
            
            NewChatView(spaceId: "CF5BDBDF-44C0-4382-AD32-D92EC05AA35E")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Event widget")
                }
            
            EventWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .event, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Event widget")
                }
            
            
            TodoWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .todo, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Event widget")
                }
            
            
            
            SearchUserView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            
            NavigationStack {

                ProfileView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
                
                
            }
            
        }
        

        
       
        
        
        
    }
}

struct FrontPageView_Previews: PreviewProvider {
    
    static var previews: some View {
//        FrontPageView(showSignInView: .constant(false), loadedColor: .constant(.red),showCreateProfileView: .constant(false))
        FrontPageView(loadedColor: .constant(.red), activeSheet: .constant(nil))
    }
}

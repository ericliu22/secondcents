//
//  FrontPageView.swift
//  TwoCents
//
//  Created by jonathan on 8/16/23.
//

import SwiftUI

struct FrontPageView: View {
    
    let CalendarTestWidget = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch")
   
    
    @Binding var loadedColor: Color
    @Binding var activeSheet: PopupSheet?
    @State var selectedTab: Int = 0
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        //Make sure TabView always navigates to SpacesView
        TabView(selection: $selectedTab, content: {
            SpacesView(activeSheet: $activeSheet, loadedColor: $loadedColor)
                .tabItem {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("Spaces")
                }
                .tag(0)
            
            NavigationStack{
                SearchUserView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
                   
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(1)
        
            
            NavigationStack {

                ProfileView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(2)
            
            
        })
        .onChange(of: appModel.shouldNavigateToSpace, {
            DispatchQueue.global().async {
                appModel.navigationMutex.lock()
                print("FRONTPAGEVIEW ACQUIRED MUTEX")
                if appModel.shouldNavigateToSpace {
                    while (appModel.inSpace && appModel.navigationSpaceId != appModel.currentSpaceId) {
                            print("FRONTPAGEVIEW WAITING")
                            appModel.navigationMutex.wait()
                    }
                    print("currentSpaceId \(appModel.currentSpaceId ?? "nil")")
                    if appModel.navigationSpaceId == appModel.currentSpaceId {
                        appModel.navigationMutex.unlock()
                        return
                    }
                    selectedTab = 0
                    appModel.correctTab = true
                    appModel.navigationMutex.broadcast()
                    print("FRONTPAGEVIEW NOT WAITING")
                }
                appModel.navigationMutex.unlock()
            }
        })
    }
}

/*
struct FrontPageView_Previews: PreviewProvider {
    
    static var previews: some View {
//        FrontPageView(showSignInView: .constant(false), loadedColor: .constant(.red),showCreateProfileView: .constant(false))
        FrontPageView(loadedColor: .constant(.red), activeSheet: .constant(nil))
    }
}

*/

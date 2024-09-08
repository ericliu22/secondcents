//
//  FrontPageView.swift
//  TwoCents
//
//  Created by jonathan on 8/16/23.
//

import SwiftUI
import Firebase

struct FrontPageView: View {
    
    let CalendarTestWidget = CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch")
   
    
    @State var friendRequests: Int = 0
    @State var selectedTab: Int = 0
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        //Make sure TabView always navigates to SpacesView
        TabView(selection: $selectedTab, content: {
            SpacesView()
                .tabItem {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("Spaces")
                }
                .tag(0)
            
            NavigationStack{
                SearchUserView(targetUserId: "")
                   
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(1)
        
            
            NavigationStack {

                ProfileView(targetUserId: "")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .badge(friendRequests)
            .tag(2)
            
            
        })
        .onAppear {
            //No error printing at all lowkey jank if something fucks up it's this
            guard let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid else {
                print("auth manager failed")
                return
            }
            db.collection("users").document(userId).addSnapshotListener({ snapshot, error in
                guard let snapshot = snapshot else {
                    print("snapshot failed")
                    return
                }
                guard let incomingFriendRequests = snapshot.get("incomingFriendRequests") as? Array<String> else {
                    print("incoming friend requests failed")
                    return
                }
                friendRequests = incomingFriendRequests.count
                print("FRIEND REQUESTS \(friendRequests)")
            })

        }
        .onChange(of: appModel.shouldNavigateToSpace,initial: true) {
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
        }
    }
}

/*
struct FrontPageView_Previews: PreviewProvider {
    
    static var previews: some View {
//        FrontPageView(showSignInView: .constant(false), appModel.loadedColor: .constant(.red),showCreateProfileView: .constant(false))
        FrontPageView(appModel.loadedColor: .constant(.red), activeSheet: .constant(nil))
    }
}

*/

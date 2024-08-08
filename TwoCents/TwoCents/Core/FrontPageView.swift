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
    @Binding var activeSheet: sheetTypes?
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
            
//            NewTodoView(spaceId: "27580F0B-A56D-468D-8E4B-2810C22E8617", closeNewWidgetview: .constant(false))
//                .frame(width: 250, height: 250)
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Event widget")
//                }
            
            EventWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, x:0, y: 0, borderColor: .red, userId: "jisookim", media: .event, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Event widget")
                }
                .tag(1)

            /*
            CalendarWidget(widget: CanvasWidget(id: UUID(uuidString: "E2C85940-3266-44F7-B6D2-4D21F507B25C")!, width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"), spaceId: "2FF491A4-CEC6-419F-A199-204810864FCF"
                            )
              
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Calendar")
                }
                .tag(2)
             */
            
            
//            CustomCalendarView(spaceId: "2FF491A4-CEC6-419F-A199-204810864FCF"
//                         , widget: CanvasWidget(id: UUID(uuidString: "E2C85940-3266-44F7-B6D2-4D21F507B25C")!, width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
//              
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("CustomCalendar")
//                }
            
            CalendarView(spaceId: "2FF491A4-CEC6-419F-A199-204810864FCF"
                         , widget: CanvasWidget(id: UUID(uuidString: "E2C85940-3266-44F7-B6D2-4D21F507B25C")!, width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .text, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
              
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Calendar")
                }
                .tag(3)
            
            
//            TodoWidget(widget: CanvasWidget(width: .infinity, height:  .infinity, borderColor: .red, userId: "jisookim", media: .todo, widgetName: "Text", widgetDescription: "A bar is a bar", textString: "Fruits can't even see so how my Apple Watch"))
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Event widget")
//                }
//            
            
            
            SearchUserView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(4)

            
            NavigationStack {

                ProfileView(activeSheet: $activeSheet, loadedColor: $loadedColor, targetUserId: "")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(5)
            
            
        })
        .onChange(of: appModel.shouldNavigateToSpace, {
            if appModel.shouldNavigateToSpace {
                
                selectedTab = 0
                appModel.correctTab = true
                
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

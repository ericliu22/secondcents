//
//  TwoCentsApp.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI
import Firebase

@main
struct TwoCentsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
           RootView()
        }
    }
}
//
//struct Previews_TwoCentsApp_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
      
        return true
    }
}

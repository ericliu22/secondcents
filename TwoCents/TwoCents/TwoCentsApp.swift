//
//  TwoCentsApp.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.

import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging
import UIKit

@main
struct TwoCentsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(delegate.appModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    var appModel: AppModel = AppModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        handleUniversalLink(url)
        return true
    }

    func handleUniversalLink(_ universalLink: URL) {
        print("Universal link URL: \(universalLink.absoluteString)")
        let components = universalLink.pathComponents
        //We want to crash the app if this fucks up because it means there is a security leak
        //Should never happen though :)
        assert(components[0] == "app")
        
        guard let action = components[safe: 1] else {
            print("Universal link has no action (e.g. space, friend, invite) ")
            return
        }
        guard let subject = components[safe: 2] else {
            print("Universal link has no subject (e.g. spaceId, friendUid, inviteId) ")
            return
        }

        //Tenatively we'll use these link actions, can change if we want it to
        switch action {
        case "space":
            print("space link")
            isValidSpaceId(spaceId: subject, completion: { [weak self] valid in
                guard let self = self else {
                    return
                }
                if valid {
                    self.appModel.spaceId = subject
                    self.appModel.shouldNavigateToSpace = true
                }
                else { print("Invalid spaceId: resuming normal execution") }
            })
        case "friend":
            print("friend link")
        case "invite":
            print("invite link")
        default:
            //Should never return if it does continue normal execution
            print("Must set switch statement of subject")
            return
        }
    }
    
    func isValidSpaceId(spaceId: String, completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("spaces").document(spaceId).getDocument(completion: { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    completion(false)
                    return
                }

                if (snapshot != nil) {
                    completion(true)
                    //This is just for safety I don't know if necessary
                    return
                }
                completion(false)
        })
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL
              else {
            return false
        }
        
        handleUniversalLink(incomingURL)
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print(deviceToken)
    }

    //Runs when app is not open and user clicks on notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        if let notificationSpaceId = userInfo["spaceId"] {
            guard let spaceId: String = notificationSpaceId as? String else {
                return
            }
            self.appModel.spaceId = spaceId
            self.appModel.shouldNavigateToSpace = true
            print("SPACEID: \(notificationSpaceId)")
            print("didReceiveRemoteNotification SPACEID: \(self.appModel.spaceId ?? "nothing")")
        }

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("GAY")
        let deviceToken: [String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken)
        uploadTokenToServer(fcmToken ?? "")
    }
    
    func uploadTokenToServer(_ token: String) {
        do {
            let uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
            db.collection("users").document(uid).setData(["token": token], merge: true)
        } catch {
            print("FAILED TO UPLOAD DEVICE TOKEN")
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    //Runs when app is open and user gets notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        completionHandler([[.banner, .badge, .sound]])
    }

    //Runs when app is open and user click notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        
        print(userInfo)
        if let notificationSpaceId = userInfo["spaceId"] {
            guard let spaceId: String = notificationSpaceId as? String else {
                return
            }
            self.appModel.spaceId = spaceId
            self.appModel.shouldNavigateToSpace = true
            print("SPACEID: \(notificationSpaceId)")
            print("didReceive SPACEID: \(self.appModel.spaceId ?? "nothing")")
        }

        completionHandler()
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

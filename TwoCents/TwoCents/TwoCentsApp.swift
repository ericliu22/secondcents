//
//  TwoCentsApp.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.

import Darwin
import Firebase
import FirebaseAuth
import FirebaseMessaging
import SwiftUI
import UIKit
import UserNotifications

@main
struct TwoCentsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(delegate.appModel!)
                .onAppear {
                    AnalyticsManager.shared.pageView(url: ANALYTICS_URL)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    var appModel: AppModel?

    //If this fucks up everyone is fucked
    override init() {
        super.init()
        print("RAN APP DELEGATE INIT")
        NSSetUncaughtExceptionHandler({ exception in
            AnalyticsManager.shared.crashEvent(exception: exception)
        })
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        appModel = AppModel()

        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(
                    types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        DispatchQueue.main.async {
            self.checkVersionWithAPI()
        }
        
        return true
    }

    func checkVersionWithAPI() {
        Task {
            do {
                // 1. Fetch the required version string from your server
                let requiredVersion = try await fetchRequiredVersion(from: "https://api.twocentsapp.com/version")
                
                // 2. Get the current app version
                let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                
                // 3. Compare
                if isOlderVersion(currentAppVersion, than: requiredVersion) {
                    // 4. Show your force-update alert
                    DispatchQueue.main.async {
                        self.showForceUpdateAlert()
                    }
                }
            } catch {
                print("Failed to check version from API: \(error)")
                // Decide if you want to handle failures differently
                // (e.g., allow user to continue, or set default required version, etc.)
                showServerOffline()
            }
        }
    }
    
    private func showServerOffline() {
        let alert = UIAlertController(
            title: "TwoCents servers unavailable",
            message: "We apologize for the inconvenience. Please try again later",
            preferredStyle: .alert
        )
        
        let updateAction = UIAlertAction(title: "Ok", style: .default) { _ in
            // Replace with your actual App Store URL
            exit(0)  // Force-close the app (not recommended by Apple)
        }
        
        alert.addAction(updateAction)
        
        // Present the alert on the key window.
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }

    
    private func showForceUpdateAlert() {
        let alert = UIAlertController(
            title: "Update Required",
            message: "A new version is required to continue. Please update now.",
            preferredStyle: .alert
        )
        
        let updateAction = UIAlertAction(title: "Update Now", style: .default) { _ in
            // Replace with your actual App Store URL
            exit(0)  // Force-close the app (not recommended by Apple)
        }
        
        alert.addAction(updateAction)
        
        // Present the alert on the key window.
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }

    /// Returns true if `current` is strictly older than `required`.
    private func isOlderVersion(_ current: String, than required: String) -> Bool {
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        let requiredComponents = required.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(currentComponents.count, requiredComponents.count) {
            let c = (i < currentComponents.count) ? currentComponents[i] : 0
            let r = (i < requiredComponents.count) ? requiredComponents[i] : 0
            
            if c < r {
                return true
            } else if c > r {
                return false
            }
        }
        return false
    }


    /// Fetches the "minimum_version" from a JSON endpoint.
    private func fetchRequiredVersion(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // For example, the JSON structure might look like {"minimum_version": "2.3"}
        struct VersionResponse: Decodable {
            let minimum_version: String
        }
        
        let decoded = try JSONDecoder().decode(VersionResponse.self, from: data)
        return decoded.minimum_version
    }


    func application(
        _ application: UIApplication, open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("Ran thing 2")

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
            print(
                "Universal link has no subject (e.g. spaceId, friendUid, inviteId) "
            )
            return
        }
        print("asdfkalsjdfalskjdflk")

        //Tenatively we'll use these link actions, can change if we want it to
        switch action {
        case "widget":
            guard let widgetId = components[safe: 3] else {
                print("Universal link has no widgetId")
                return
            }

            Task {
                if await !validWidgetLink(spaceId: subject) {
                    print("Invalid widget link")
                    return
                }

                appModel?.navigationRequest = .space(
                    spaceId: subject, widgetId: widgetId)
            }
        case "space":
            print("space link")

            isValidSpaceLink(
                spaceId: subject,
                completion: { [weak self] valid in
                    guard let self = self else {
                        return
                    }

                    if valid {
                        guard let appModel = appModel else {
                            print("AppModel not yet initialized")
                            return
                        }

                        appModel.navigationRequest = .space(
                            spaceId: subject, widgetId: nil)

                    } else {
                        print("Invalid spaceId: resuming normal execution")
                    }
                })
        case "friend":
            print("friend link")
        case "invite":
            print("invite link")
            guard let spaceToken = components[safe: 3] else {
                print("Universal link has no spaceJwtToken")
                return
            }

            guard let appModel = appModel else {
                print("AppModel not initialized yet")
                return
            }
            appModel.activeSheet = .joinSpaceView(
                spaceId: subject, spaceToken: spaceToken)
        default:
            //Should never return if it does continue normal execution
            print("Must set switch statement of subject")
            return
        }
    }

    func isValidSpaceLink(spaceId: String, completion: @escaping (Bool) -> Void)
    {
        Firestore.firestore().collection("spaces").document(spaceId)
            .getDocument(completion: { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    completion(false)
                    return
                }

                if snapshot != nil {
                    completion(true)
                    //This is just for safety I don't know if necessary
                    return
                }
                completion(false)
            })
    }

    func validWidgetLink(spaceId: String) async -> Bool {
        guard
            let space = try? await SpaceManager.shared.getSpace(
                spaceId: spaceId)
        else {
            print("Failed to fetch space")
            return false
        }
        guard let user = appModel?.user else {
            print("No authenticated user")
            return false
        }
        guard
            let inSpace = space.members?.contains(where: { member in
                user.userId == member
            })
        else {
            print("Space has no members")
            return false
        }
        return inSpace
    }

    func application(
        _ application: UIApplication, continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        print("Ran thing 1")
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
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (
            UIBackgroundFetchResult
        ) -> Void
    ) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Forward the notification to FirebaseAuth
        if Auth.auth().canHandleNotification(userInfo) {
            print("Forwarded to firebase")
            completionHandler(.noData)
            return
        }

        print(userInfo)

        if let notificationSpaceId = userInfo["spaceId"] {
            guard let spaceId: String = notificationSpaceId as? String else {
                return
            }

            guard let appModel = appModel else {
                print("AppModel not yet initialized")
                return
            }
            let widgetId = userInfo["widgetId"] as? String
            appModel.navigationRequest = .space(
                spaceId: spaceId, widgetId: widgetId)
            print(
                "didReceiveRemoteNotification SPACEID: \(spaceId ?? "nothing")")
        }

        completionHandler(.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?
    ) {

        let deviceToken: [String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken)
        uploadTokenToServer(fcmToken ?? "")
    }

    func uploadTokenToServer(_ token: String) {
        do {
            let uid = try AuthenticationManager.shared.getAuthenticatedUser()
                .uid
            db.collection("usersPrivate").document(uid).setData(
                ["token": token], merge: true)
        } catch {
            print("FAILED TO UPLOAD DEVICE TOKEN")
        }
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

    //Runs when app is open and user gets notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        if UIApplication.shared.applicationState == .active {
            
            print("Received shit r")
            guard let user = appModel?.user else {
                completionHandler([])
                return
            }
            let title = notification.request.content.title
            let message = notification.request.content.body
            
            guard let notificationUserId = userInfo["userId"] as? String else {
                appModel?.showNotification(title: title, message: message)
                completionHandler([])
                return
            }
            if user.userId != notificationUserId {
                appModel?.showNotification(title: title, message: message, spaceId: userInfo["spaceId"] as? String, widgetId: userInfo["widgetId"] as? String)
            }

            completionHandler([])
        } else {
            completionHandler([[.banner, .badge, .sound]])
        }

    }

    //Runs when app is open and user click notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        print("ran bitch 1")
        if let messageID = userInfo[gcmMessageIDKey] {
            print(
                "Message ID from userNotificationCenter didReceive: \(messageID)"
            )
        }
        // Get the current badge number
        let currentBadgeNumber = UIApplication.shared.applicationIconBadgeNumber
        UNUserNotificationCenter.current().setBadgeCount(currentBadgeNumber + 1)

        print(userInfo)
        if let notificationSpaceId = userInfo["spaceId"] {
            guard let spaceId: String = notificationSpaceId as? String else {
                return
            }
            guard let appModel = appModel else {
                print("AppModel not yet initialized")
                return
            }

            let widgetId = userInfo["widgetId"] as? String
            appModel.navigationRequest = .space(
                spaceId: spaceId, widgetId: widgetId)
            print("SPACEID: \(notificationSpaceId)")
            print("didReceive SPACEID: \(spaceId ?? "nothing")")
        }

        completionHandler()
    }
}

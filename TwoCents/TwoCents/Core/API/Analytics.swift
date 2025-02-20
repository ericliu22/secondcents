//
//  Crash.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/12.
//

import Foundation
import Darwin

let ANALYTICS_URL = "https://analytics.twocentsapp.com"

final class AnalyticsManager {
    static func crashEvent(exception: NSException) {
        let exception_name: String = exception.name.rawValue
        let exception_reason: String = exception.reason ?? "unknown_reason"
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        
        let props: [String: Any] = [
            "Exception Name": exception_name,
            "Exception Reason": exception_reason,
            "App Version": appVersion
        ]
        logEvent("crash", parameters: props)
    }
    
    private static func sendPlausible(name: String, url: String = ANALYTICS_URL, props: [String: Any]? = nil) {
            let url = URL(string: "\(ANALYTICS_URL)/api/event")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            
            var payload: [String: Any] = [
                "name": name,
                "url": ANALYTICS_URL,
                "domain": "api.twocentsapp.com",
            ]
            
            if let props {
                payload["props"] = props
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to send analytics: \(error)")
                } else {
                    print("Analytics sent successfully.")
                }
            }
            task.resume()
        }
    
    private static func logEvent(_ name: String, parameters: [String: Any]) {
        
        sendPlausible(name: name, props: parameters)
    }
    
    static func login() {
        logEvent("login", parameters: [
            "time": Date().description(with: Locale(identifier: "en_US"))
        ])
    }
    
    static func register() {
        logEvent("register", parameters: [
            "time": Date().description(with: Locale(identifier: "en_US"))
        ])
    }

    static func openedApp() {
        logEvent("opened_app", parameters: [
            "time": Date().description(with: Locale(identifier: "en_US"))
        ])
        logEvent("pageview", parameters: [:])
    }
    
    static func joinSpace(spaceId: String, method: String) {
        logEvent("join_space", parameters: [
            "spaceId": spaceId,
            "method": method
        ])
    }
    
    static func messageSend(message: any Message) {
        logEvent("message_send", parameters: [
            "message_type": message.messageType.rawValue
        ])
    }
    
    static func widgetCreated(widget: CanvasWidget) {
        logEvent("widget_created", parameters: [
            "userId": widget.userId,
            "media": widget.media.name(),
        ])
    }
    
    static func tickle(userId: String, targetUserId: String, count: Int = 1) {
        logEvent("tickle", parameters: [
            "userId": userId,
            "count": count,
            "targetUserId": targetUserId
        ])
    }
}

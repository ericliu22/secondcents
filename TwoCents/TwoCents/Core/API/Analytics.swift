//
//  Crash.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/12.
//

import Foundation
import Darwin
import UIKit

let ANALYTICS_URL = "https://analytics.twocentsapp.com"

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private func sendPlausible(name: String, url: String = ANALYTICS_URL, props: [String: Any]? = nil) {
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
    
    func crashEvent(exception: NSException) {
        let exception_name: String = exception.name.rawValue
        let exception_reason: String = exception.reason ?? "unknown_reason"
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        
        let props: [String: Any] = [
            "Exception Name": exception_name,
            "Exception Reason": exception_reason,
            "App Version": appVersion
        ]
        
        sendPlausible(name: "Crash", props: props)
    }
    
    func pageView(url: String, props: [String: Any]) {
        sendPlausible(name: "pageview", url: url, props: props)
    }
    
    func messageSend() {
        sendPlausible(name: "Message Send")
    }
    
    func widgetCreated(widget: CanvasWidget) {
        let props: [String: Any] = [
            "Widget Type": widget.media.name()
        ]
        sendPlausible(name: "Widget Created")
    }
    
    func tickle(count: Int = 1) {
        let props: [String: Any] = [
            "Tickle Count": count
        ]
        sendPlausible(name: "Tickle", props: props)
    }
}

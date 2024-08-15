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
                print("Failed to send crash data: \(error)")
            } else {
                print("Crash data sent successfully.")
            }
        }
        task.resume()
    }
    
    func crashEvent(exception: NSException) {
        let exception_name: String = exception.name.rawValue
        let exception_reason: String = exception.reason ?? "unknown_reason"
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        
        var props: [String: Any] = [
            "os": "iOS",
            "exception_name": exception_name,
            "exception_reason": exception_reason,
            "signal": signal,
            "app_version": appVersion
        ]
        
        sendPlausible(name: "crash_event", props: props)
    }
    
    func pageView(url: String, props: [String: Any]) {
        sendPlausible(name: "pageview", url: url, props: props)
    }
    
    func messageSend() {
        sendPlausible(name: "message_send")
    }
    
}

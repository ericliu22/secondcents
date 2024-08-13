//
//  Crash.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/12.
//

import Foundation
import Darwin

let ANALYTICS_URL = "https://analytics.twocentsapp.com"

func signalListener() {
    //For crash analytics
    signal(SIGABRT, handleSignal)
    signal(SIGSEGV, handleSignal)
    signal(SIGILL, handleSignal)
    signal(SIGFPE, handleSignal)
    signal(SIGBUS, handleSignal)
}

func handleSignal(signal: Int32) {
    // Capture the signal and send the crash data
    sendCrashDataToPlausible(signal: signal)
}

func sendCrashDataToPlausible(exception: NSException? = nil, signal: Int32? = nil) {
    let url = URL(string: "\(ANALYTICS_URL)/api/event")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Construct the payload with the relevant crash details
    var payload: [String: Any] = [
        "event_name": "app_crash",
        "properties": [
            "os": "iOS",
            "app_version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "unknown",
            "platform": "Swift"
        ]
    ]
    
    if let exception = exception {
        payload["exception_name"] = exception.name.rawValue
        payload["exception_reason"] = exception.reason ?? "unknown"
    }
    
    if let signal = signal {
        payload["signal"] = signal
    }
    
    // Convert the payload to JSON
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Send the request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Failed to send crash data: \(error)")
        } else {
            print("Crash data sent successfully.")
        }
    }
    task.resume()
}
